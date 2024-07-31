<#
    .SYNOPSIS
    This script updates the Teams Phone Number Management (TPNM) database by checking if the requested allocations have been used in Teams and if the assigned allocations have been removed from Teams.
    It also checks if all used PSTN numbers in Teams are listed in the TPNM allocation table and adds any missing numbers.

    .DESCRIPTION
    This script connects to Azure, Teams, and the TPNM database using the Managed Identity of the Azure Automation Account.
    It then performs the following tasks:
    1. Checks if the requested allocations have been used in Teams.
        - If a number has been assigned to a Teams EV user, it updates the state column of the specific row in the allocation table to 'Assigned'.
        - If a number has been assigned to multiple users, it displays a warning message.
        - If a number has not been assigned to any user, it removes the specific row from the allocation table.
    2. Checks if the assigned allocations have been removed from Teams.
        - If a number has been removed from a Teams EV user or the user has been deleted, it removes the specific row from the allocation table.
        - If a number has been assigned to multiple users, it displays a warning message.
    3. Checks if all used PSTN numbers in Teams are listed in the TPNM allocation table.
        - If a number is not listed, it adds the specific row to the allocation table with the state 'Assigned'.

    .PARAMETER TPNMAuto_SQLServerName
    The name of the SQL Server hosting the TPNM database.
    By default, it retrieves the value from the Azure Automation Variable 'TPNMAuto_SQLServerName'.

    .PARAMETER TPNMAuto_SQLDatabaseName
    The name of the TPNM database.
    By default, it retrieves the value from the Azure Automation Variable 'TPNMAuto_SQLDatabaseName'.

    .PARAMETER TPNMAuto_PhoneNumberAssigmentResultSize
    The number of PSTN numbers to retrieve from Teams.
    Should be equal to or greater than the maximum expected number of PSTN numbers in Teams.
    By default, it retrieves the value from the Azure Automation Variable 'TPNMAuto_PhoneNumberAssigmentResultSize'.

    .EXAMPLE
    .\Update-TPNMDatabase.ps1
    This example runs the script with the default parameter values retrieved from the Azure Automation Variables.
    Please check the TPNM deployment guide for more information on how to set up these automation variables.

    .EXAMPLE
    .\Update-TPNMDatabase.ps1 -TPNMAuto_SQLServerName 'myserver' -TPNMAuto_SQLDatabaseName 'mydatabase' -TPNMAuto_PhoneNumberAssigmentResultSize 100

    This example runs the script with custom parameter values.
#>

[CmdletBinding()]
param (
    [String]
    $TPNMAuto_SQLServerName = (Get-AutomationVariable -Name 'TPNMAuto_SQLServerName'),

    [String]
    $TPNMAuto_SQLDatabaseName = (Get-AutomationVariable -Name 'TPNMAuto_SQLDatabaseName'),

    [int]
    $TPNMAuto_PhoneNumberAssigmentResultSize = (Get-AutomationVariable -Name 'TPNMAuto_PhoneNumberAssigmentResultSize') # The number of PSTN numbers to retrieve from Teams. Should be equal or greater your maximum expected number of PSTN numbers in Teams.
)

#region Additional Helper Functions

function Write-DebugToOutputStream {
    <#
    .SYNOPSIS
    Write a debug message to the output stream of the Azure Automation job.
    
    .DESCRIPTION
    Azure Automation does not have a debug stream for the job output.
    Therefore, we have to use the output stream of the job to write debug messages.
    This function will write a debug message to the output stream of the Azure Automation job.
    
    .PARAMETER Message
    String value of the debug message
    
    .EXAMPLE
    Write-DebugToOutputStream -Message 'This is my debug message'

    This example will write the debug message 'This is my debug message' to the output stream of the Azure Automation job.

    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $Message
    )
	
    Write-Debug -Message $Message 5>&1
}

#endregion

#region Connect to Azure, Teams and TPNM database

# Enable debug logging to debug stream of Azure Automation
# All debug messages will be written to the output stream of the Azure Automation job
# This is needed, because Azure Automation does not have a debug stream for the job output
$global:DebugPreference = "Continue"

# Connect to Azure using the Managed Identity of the Azure Automation Account
Write-DebugToOutputStream -Message 'Connecting to Azure...'
Connect-AzAccount -Identity
Write-DebugToOutputStream -Message '...OK'

# Connect to Teams using the Managed Identity of the Azure Automation Account
Write-DebugToOutputStream -Message 'Connecting to Teams...'
Connect-MicrosoftTeams -Identity
Write-DebugToOutputStream -Message '...OK'

# Connect to TPNM database
Write-DebugToOutputStream -Message 'Connecting to the TPNM database...'
Connect-TPNMDatabase -SqlServerName $TPNMAuto_SQLServerName -SqlDatabaseName $TPNMAuto_SQLDatabaseName
Write-DebugToOutputStream -Message '...OK'

#endregion

#region Update TPNM: Check, if the requested allocations have been used in Teams

# Read the requested TPNM allocation table from the Azure SQL database
Write-DebugToOutputStream -Message 'Getting requested allocations from the database...'
$requested = Get-TPNMAllocation -AllocationState 'Requested' -ResultSize unlimited
Write-DebugToOutputStream -Message '...OK'

# Check, if the requested allocations have been used in Teams (number has been assigned to a Teams EV user)
# If yes, update the state column of the specific row in the allocation table to 'Assigned'
# If no, remove the specific row from the allocation table
foreach ($row in $requested) {
    $number = $row.CountryCode + $row.ExtRangeSpan + $row.AllocationExtension
    $csOnlineUser = Get-CsPhoneNumberAssignment -TelephoneNumber $number -ErrorAction SilentlyContinue
    if ($null -ne $csOnlineUser -and $csOnlineUser.count -eq 1) {
        Write-DebugToOutputStream -Message "The number $number has been assigned to the user $($csOnlineUser.UserPrincipalName) in Teams! Updating the state of the allocation to 'Assigned'..."
        Set-TPNMAllocation -AllocationId $row.AllocationId -AllocationState 'Assigned' -Confirm:$false
        Set-TPNMAllocation -AllocationId $row.AllocationId -AllocationDescription $csonlineuser.AssignedPstnTargetId -Confirm:$false
    }
    elseif ($null -ne $csOnlineUser -and $csOnlineUser.count -gt 1) {
        Write-Warning "The number $number has been assigned to multiple users in Teams! Must be checked manually..."
    }
    else {
        Write-DebugToOutputStream -Message "The number $number has NOT been assigned to a user in Teams! Removing the allocation from the database..."
        Remove-TPNMAllocation -AllocationId $row.AllocationId -Confirm:$false
    }
    Write-DebugToOutputStream -Message '...OK'
}

#endregion

#region Update TPNM: Check, if the assigned allocations have been removed from Teams

# Read the assigned TPNM allocation table from the Azure SQL database
Write-DebugToOutputStream -Message 'Getting assigned allocations from the database...'
$assigned = Get-TPNMAllocation -AllocationState 'Assigned' -ResultSize unlimited
Write-DebugToOutputStream -Message '...OK'

# Check, if the assigned allocations have been removed from Teams (number has been removed from a Teams EV user or the user has been deleted)
# If yes, remove the specific row from the allocation table
foreach ($row in $assigned) {
    $number = $row.CountryCode + $row.ExtRangeSpan + $row.AllocationExtension
    $csOnlineUser = Get-CsPhoneNumberAssignment -TelephoneNumber $number -ErrorAction SilentlyContinue
    if ($null -eq $csOnlineUser) {
        Write-DebugToOutputStream -Message "The number $number has not been used to any user in Teams! Removing the allocation from the database..."
        Remove-TPNMAllocation -AllocationId $row.AllocationId -Confirm:$false
    }
    elseif ($null -ne $csOnlineUser -and $csOnlineUser.count -gt 1) {
        Write-Warning "The number $number has been assigned to multiple users in Teams! Must be checked manually..."
    }
    else {
        Write-DebugToOutputStream -Message "The number $number has been assigned to the user $($csOnlineUser.UserPrincipalName) in Teams! Keeping the allocation in the database..."
    }
    Write-DebugToOutputStream -Message '...OK'
}

#endregion

#region Update TPNM: Check, if all used PSTN numbers in Teams are listed in the TPNM allocation table

# Get all PSTN numbers from Teams
Write-DebugToOutputStream -Message 'Getting all PSTN numbers from Teams...'
$allPSTNNumbers = Get-CsPhoneNumberAssignment -Top $TPNMAuto_PhoneNumberAssigmentResultSize | Select-Object -Property TelephoneNumber, AssignedPstnTargetId
Write-DebugToOutputStream -Message '...OK'

# Read the TPNM ranges table from the Azure SQL database
Write-DebugToOutputStream -Message 'Getting all ranges from the database...'
$ranges = Get-TPNMExtRange -ResultSize unlimited
Write-DebugToOutputStream -Message '...OK'

# Check, if all used PSTN numbers in Teams are listed in the TPNM allocation table
# If not, add the specific row to the allocation table with the state 'Assigned'
foreach ($number in $allPSTNNumbers) {
    $rangefound = $false
    $resultObject = @{}
    foreach ($range in $ranges) {
        $fullrange = '{0}{1}' -f $range.CountryCode, $range.ExtRangeSpan
        if ($number.TelephoneNumber -like "$fullrange*") {
            $resultObject = @{
                ExtRangeId           = $range.ExtRangeId
                AllocationExtension  = $number.Telephonenumber.replace("$fullrange", "")
                AssignedPstnTargetId = $number.AssignedPstnTargetId
            }
            $rangefound = $true
            break
        }
    }
    # If the number is not part of any existing range, skip to the next number
    if ($rangefound -eq $false) {
        Write-Warning "The number $($number.telephonenumber) is not part of any existing range. Continuing with the next number."
        continue
    }

    # Check if the number is already listed in the allocation table
    # If not, add the allocation to the database
    $allocation = Get-TPNMAllocation -ExtRangeId $resultObject.ExtRangeId -AllocationExtension $resultObject.AllocationExtension
    if ($null -ne $allocation) {
        Write-DebugToOutputStream -Message "The number $($number.telephonenumber) is already listed in the allocation table (State: $($allocation.AllocationState), CreatedOn: $($allocation.AllocationCreatedOn), Description: $($allocation.AllocationDescription))! Continuing with the next number."
        continue
    }

    # Add the allocation to the database
    Write-DebugToOutputStream -Message "The number $($number.telephonenumber) is not listed in the allocation table! Adding the allocation to the database..."
    Add-TPNMAllocation -ExtRangeId $resultObject.ExtRangeId -AllocationExtension $resultObject.AllocationExtension -AllocationState 'Assigned' -AllocationDescription $resultObject.AssignedPstnTargetId
    Write-DebugToOutputStream -Message '...OK'
}

#endregion

#region Disconnect from Azure, Teams and TPNM database

# Disconnect from Azure
Write-DebugToOutputStream -Message 'Disconnecting from Azure...'
Disconnect-AzAccount
Write-DebugToOutputStream -Message '...OK'

# Disconnect from Teams
Write-DebugToOutputStream -Message 'Disconnecting from Teams...'
Disconnect-MicrosoftTeams
Write-DebugToOutputStream -Message '...OK'

# Disconnect from TPNM database
Write-DebugToOutputStream -Message 'Disconnecting from the TPNM database...'
Disconnect-TPNMDatabase
Write-DebugToOutputStream -Message '...OK'

#endregion