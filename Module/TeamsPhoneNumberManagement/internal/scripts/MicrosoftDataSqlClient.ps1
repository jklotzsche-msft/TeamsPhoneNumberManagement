[CmdletBinding()]
param()

# Load the Microsoft.Data.SqlClient assembly for SQL connectivity based on the current system
## Identify the net framework version: net9.0, net8.0 or net462
$netVersion = [System.Environment]::Version
if ($netVersion.Major -ge 9) {
    $framework = "net9.0"
}
elseif ($netVersion.Major -eq 8) {
    $framework = "net8.0"
}
elseif ($netVersion.Major -eq 4) {
    $framework = "net462"
}
else {
    throw "Unsupported .NET version for Microsoft.Data.SqlClient: $($netVersion.ToString())"
}

## Identify the net platform: win or unix
if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
    $platform = "win"
}
else {
    $platform = "unix"
}

## Identify the net architecture: x64, x86 or arm64
$architecture = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture.ToString().ToLower()

# Load the Microsoft.Data.SqlClient assembly from the target directory
$targetDir = "$PSScriptRoot\..\..\bin\$framework\$platform\$architecture"
if (-not (Test-Path -Path $targetDir)) {
    throw "Target directory does not exist: $targetDir"
}
Write-Verbose -Message "Loading Microsoft.Data.SqlClient assembly from $targetDir"
Add-Type -Path (Join-Path -Path $targetDir -ChildPath 'Microsoft.Data.SqlClient.dll')