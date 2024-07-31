param (
	[string]
	$Repository = 'PSGallery',

	[string]
	$ResourceGroupName,

	[string]
	$FunctionAppName,

	[switch]
	$ReturnPublishResult
)

# Check, if PowerShell connection to Azure is established
Write-Host 'Checking, if connection to Azure has been established...' -NoNewline
if ($null -eq (Get-AzContext) -and $ResourceGroupName -and $FunctionAppName) {
	$exception = [System.InvalidOperationException]::new('Not yet connected to the Azure Service. Use "Connect-AzAccount -TenantId <TenantId>" to establish a connection and select the correct subscription using "Set-AzContext"!')
	$errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, 'NotConnected', 'InvalidOperation', $null)
	
	$PSCmdlet.ThrowTerminatingError($errorRecord)
}
Write-Host 'OK' -ForegroundColor Green

# prepare variables
$workingDirectory = Split-Path -Path $PSScriptRoot
$moduleFolder = Join-Path -Path (Split-Path -Path $workingDirectory) -ChildPath "Module"
$config = Import-PowerShellDataFile -Path "$PSScriptRoot\build.config.psd1"

# Prepare output path and copy function folder
Remove-Item -Path "$workingDirectory/publish" -Recurse -Force -ErrorAction Ignore
$buildFolder = New-Item -Path $workingDirectory -Name 'publish' -ItemType Directory -Force -ErrorAction Stop
Copy-Item -Path "$workingDirectory/function/*" -Destination $buildFolder.FullName -Recurse -Force

# Process Dependencies
<#
$requiredModules = (Import-PowerShellDataFile -Path "$moduleFolder/TeamsPhoneNumberManagement/TeamsPhoneNumberManagement.psd1").RequiredModules
foreach ($module in $requiredModules) {
	Save-Module -Name $module -Path "$($buildFolder.FullName)/modules" -Force -Repository $Repository
}
#>

# Process Function Module
# Copy-Item -Path "$moduleFolder/TeamsPhoneNumberManagement" -Destination "$($buildFolder.FullName)/modules" -Force -Recurse
# $commands = Get-ChildItem -Path "$($buildFolder.FullName)/modules/TeamsPhoneNumberManagement/Functions" -Recurse -Filter *.ps1 | ForEach-Object BaseName
# Update-ModuleManifest -Path "$($buildFolder.FullName)/modules/TeamsPhoneNumberManagement/TeamsPhoneNumberManagement.psd1" -FunctionsToExport $commands
# Save-Module -Name "TeamsPhoneNumberManagement" -Path "$($buildFolder.FullName)/modules" -Force -Repository $Repository

# Generate Http Trigger
$httpCode = Get-Content -Path "$PSScriptRoot\functionHttp\run.ps1" | Join-String -Separator "`n"
$httpConfig = Get-Content -Path "$PSScriptRoot\functionHttp\function.json" | Join-String -Separator "`n"
foreach ($command in Get-ChildItem -Path "$moduleFolder\TeamsPhoneNumberManagement\functions\httpTrigger" -Recurse -File -Filter *.ps1) {
	$authLevel = $config.HttpTrigger.AuthLevel
	if ($config.HttpTrigger.AuthLevelOverrides.$($command.BaseName)) {
		$authLevel = $config.HttpTrigger.AuthLevelOverrides.$($command.BaseName)
	}
	$method = $config.HttpTrigger.Method
	if ($config.HttpTrigger.MethodOverrides.$($command.BaseName)) {
		$method = $config.HttpTrigger.MethodOverrides.$($command.BaseName)
	}
	$endpointFolder = New-Item -Path $buildFolder.FullName -Name $command.BaseName.Replace('-TPNM', '') -ItemType Directory
	$httpCode -replace '%COMMAND%', $command.BaseName | Set-Content -Path "$($endpointFolder.FullName)\run.ps1"
	$newHttpConfig = $httpConfig -replace '%AUTHLEVEL%', $authLevel
	$newHttpConfig -replace '%METHOD%', $method | Set-Content -Path "$($endpointFolder.FullName)\function.json"
}

# Generate Timer Trigger
$timerCode = Get-Content -Path "$PSScriptRoot\functionTimer\run.ps1" | Join-String "`n"
$timerConfig = Get-Content -Path "$PSScriptRoot\functionTimer\function.json" | Join-String "`n"
foreach ($command in Get-ChildItem -Path "$moduleFolder\TeamsPhoneNumberManagement\functions\timerTrigger" -Recurse -File -Filter *.ps1) {
	$schedule = $config.TimerTrigger.Schedule
	if ($config.TimerTrigger.ScheduleOverride.$($command.BaseName)) {
		$schedule = $config.TimerTrigger.ScheduleOverride.$($command.BaseName)
	}
	$endpointFolder = New-Item -Path $buildFolder.FullName -Name $command.BaseName -ItemType Directory
	$timerCode -replace '%COMMAND%', $command.BaseName | Set-Content -Path "$($endpointFolder.FullName)\run.ps1"
	$timerConfig -replace '%SCHEDULE%', $schedule | Set-Content -Path "$($endpointFolder.FullName)\function.json"
}

# Package & Cleanup
Remove-Item -Path "$workingDirectory/Function.zip" -Recurse -Force -ErrorAction Ignore
Compress-Archive -Path "$($buildFolder.FullName)/*" -DestinationPath "$workingDirectory/Function.zip"
Remove-Item -Path $buildFolder.FullName -Recurse -Force -ErrorAction Ignore

if ($ResourceGroupName -and $FunctionAppName) {
	Write-Host "Publishing Function App to $ResourceGroupName/$FunctionAppName..." -NoNewline
	$publishingResult = Publish-AzWebApp -ResourceGroupName $ResourceGroupName -Name $FunctionAppName -ArchivePath "$workingDirectory/Function.zip" -Confirm:$false -Force
	Write-Host 'OK' -ForegroundColor Green
	if ($ReturnPublishResult) {
		$publishingResult
	}
}