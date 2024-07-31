#requires -Module 'TeamsPhoneNumberManagement'

param (
	$Request,
	
	$TriggerMetadata
)


Write-Host "Trigger: %COMMAND% has been invoked"

# Get the caller information
<#
Write-Host "Getting caller information"
$callerInfo = @{
	"Request"           = $Request
	"Trigger"           = $TriggerMetadata
	"UserName"          = $TriggerMetadata.Headers.'X-MS-CLIENT-PRINCIPAL-NAME'
	"UserID"            = $TriggerMetadata.Headers.'X-MS-CLIENT-PRINCIPAL-ID'
	"UserIsApplication" = [bool]($TriggerMetadata.Headers.'X-MS-CLIENT-PRINCIPAL-NAME' -as [guid])
}
#>

$parameters = Get-RestParameter -Request $Request -Command %COMMAND%
$script:requestUri = $Request.RequestUri.AbsoluteUri # Save the request URI for the nextLink
$script:isFunctionApp = $true # Prepare the IsFunctionApp variable for the Push-TPNMResultSet function

# Set the Verbose and Debug parameters for debugging purposes
if ($parameters.Verbose -eq "True") { $parameters.Verbose = $true }
else { $parameters.Verbose = $false }
if ($parameters.Debug -eq "True") { $parameters.Debug = $true }
else { $parameters.Debug = $false }

# Connect to the database
if ($null -eq (Get-TPNMDatabaseConnection).State) {
	Connect-TPNMDatabase -SqlServerName $env:SqlServerName -SqlDatabaseName $env:SqlDatabaseName -Verbose:$parameters.Verbose -Debug:$parameters.Debug -ErrorAction Stop
}

try {
	$results = %COMMAND% @parameters -ErrorAction Stop
}
catch {
	$_ | Out-String | ForEach-Object {
		foreach ($line in ($_ -split "`n")) {
			Write-Warning $line
		}
	}
	Write-FunctionResult -Status InternalServerError -Body "$_"
	return
}
Write-FunctionResult -Status OK -Body $results