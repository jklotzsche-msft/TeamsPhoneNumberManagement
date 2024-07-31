<#
This script publishes the module to the gallery.
It expects as input an ApiKey authorized to publish the module.

Insert any build steps you may need to take before publishing it here.
#>
param (
	$ApiKey,
	
	$WorkingDirectory,
	
	$Repository = 'PSGallery',
	
	[switch]
	$LocalRepo,
	
	[switch]
	$SkipPublish,
	
	[switch]
	$AutoVersion
)

#region Handle Working Directory Defaults
if (-not $WorkingDirectory) {
	if ($env:RELEASE_PRIMARYARTIFACTSOURCEALIAS) {
		$WorkingDirectory = Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath $env:RELEASE_PRIMARYARTIFACTSOURCEALIAS
	}
	else { $WorkingDirectory = $env:SYSTEM_DEFAULTWORKINGDIRECTORY }
}
if (-not $WorkingDirectory) { $WorkingDirectory = Split-Path $PSScriptRoot }
#endregion Handle Working Directory Defaults

# Prepare publish folder
Write-Host "Creating and populating publishing directory"
$publishDir = New-Item -Path $WorkingDirectory -Name publish -ItemType Directory -Force
Copy-Item -Path "$($WorkingDirectory)\TeamsPhoneNumberManagement" -Destination $publishDir.FullName -Recurse -Force

#region Remove any file except .ps1, .psm1 and .psd1
Get-ChildItem -Path "$($publishDir.FullName)\TeamsPhoneNumberManagement" -Recurse -File | Where-Object { $_.Extension -notin @('.ps1', '.psm1', '.psd1') } | ForEach-Object {
	Remove-Item -Path $_.FullName -Force
}

#region Updating the Module Version
if ($AutoVersion) {
	Write-Host  "Updating module version numbers."
	try { [version]$remoteVersion = (Find-Module 'TeamsPhoneNumberManagement' -Repository $Repository -ErrorAction Stop).Version }
	catch {
		throw "Failed to access $($Repository) : $_"
	}
	if (-not $remoteVersion) {
		throw "Couldn't find TeamsPhoneNumberManagement on repository $($Repository) : $_"
	}
	$newBuildNumber = $remoteVersion.Build + 1
	[version]$localVersion = (Import-PowerShellDataFile -Path "$($publishDir.FullName)\TeamsPhoneNumberManagement\TeamsPhoneNumberManagement.psd1").ModuleVersion
	Update-ModuleManifest -Path "$($publishDir.FullName)\TeamsPhoneNumberManagement\TeamsPhoneNumberManagement.psd1" -ModuleVersion "$($localVersion.Major).$($localVersion.Minor).$($newBuildNumber)"
}
#endregion Updating the Module Version

#region Publish
if ($SkipPublish) {
	Write-Host "Compressing module to $($publishDir.FullName)\TeamsPhoneNumberManagement.zip"
	Compress-Archive -Path "$($publishDir.FullName)\TeamsPhoneNumberManagement" -Destination "$($publishDir.FullName)\TeamsPhoneNumberManagement.zip" -Force
	# Cleanup
	Remove-Item -Path "$($publishDir.FullName)\TeamsPhoneNumberManagement" -Recurse -Force
	return
}
if ($LocalRepo) {
	# Dependencies must go first
	Write-Host  "Creating Nuget Package for module: PSFramework"
	New-PSMDModuleNugetPackage -ModulePath (Get-Module -Name PSFramework).ModuleBase -PackagePath .
	Write-Host  "Creating Nuget Package for module: TeamsPhoneNumberManagement"
	New-PSMDModuleNugetPackage -ModulePath "$($publishDir.FullName)\TeamsPhoneNumberManagement" -PackagePath .
}
else {
	# Publish to Gallery
	Write-Host  "Publishing the TeamsPhoneNumberManagement module to $($Repository)"
	Publish-Module -Path "$($publishDir.FullName)\TeamsPhoneNumberManagement" -NuGetApiKey $ApiKey -Force -Repository $Repository
}
#endregion Publish