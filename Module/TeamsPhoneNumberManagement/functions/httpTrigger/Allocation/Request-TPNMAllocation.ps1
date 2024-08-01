function Request-TPNMAllocation {
    <#
        .SYNOPSIS
        Requests a new TPNM allocation.

        .DESCRIPTION
        The Request-TPNMAllocation function requests a new allocation for a TPNM (Telephone Number Management) system.
        It queries the available ranges and extensions in use, finds the next free number, and adds it to the allocation table with the state 'Requested'.

        .PARAMETER CountryId
        The ID of the country.
        It should be a string with a maximum of 5 digits.

        .PARAMETER DepartmentId
        The ID of the department.
        It should be a string with a maximum of 5 digits.

        .PARAMETER ExtRangeId
        The ID of the extension range.
        It should be a string with a maximum of 5 digits.

        .PARAMETER EnableLeadingZero
        Switch parameter to enable leading zeros in the extension number.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Request-TPNMAllocation -CountryId "12345"

        This example requests a new TPNM allocation for the specified country ID.

        .EXAMPLE
        Request-TPNMAllocation -DepartmentId "12345"

        This example requests a new TPNM allocation for the specified department ID.

        .EXAMPLE
        Request-TPNMAllocation -ExtRangeId "12345"

        This example requests a new TPNM allocation for the specified extension range ID.

        .NOTES
        - This function requires the Get-TPNMExtRange, Get-TPNMExtensionInUse, Get-TPNMNextFreeNumberByExtRange, Invoke-TPNMSqlRequest, Get-TPNMAllocation, and Push-TPNMResultSet functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses confirmation by default before executing the database query.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(DefaultParameterSetName = 'ExtRangeId', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'CountryId')]
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $CountryId,

        [Parameter(Mandatory = $true, ParameterSetName = 'DepartmentId')]
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $DepartmentId,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExtRangeId')]
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $ExtRangeId,

        [Parameter(DontShow = $true)]
        [switch]
        $EnableLeadingZero
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # Prepare hashtable for splatting
        $getTpnmSplat = @{
            ResultSize = "unlimited"
        }
        
        # Add the parameters to the hashtable as provided
        if ($CountryId) { $getTpnmSplat.CountryId = $CountryId }
        if ($DepartmentId) { $getTpnmSplat.DepartmentId = $DepartmentId }
        if ($ExtRangeId) { $getTpnmSplat.ExtRangeId = $ExtRangeId }

        # Get the ranges based on the provided parameters
        Write-Verbose "Querying ranges with $($getTPNMsplat.Keys) = $($getTPNMsplat.Values)"
        $ranges = [System.Collections.Generic.List[pscustomobject]]::new()
        Get-TPNMExtRange @getTpnmSplat | ForEach-Object { $ranges.Add($_) }

        # Get the extensions in use based on the provided parameters
        Write-Verbose "Querying extensions in use with $($getTPNMsplat.Keys) = $($getTPNMsplat.Values)"
        $extensionsInUse = [System.Collections.Generic.List[pscustomobject]]::new()
        Get-TPNMExtensionInUse @getTPNMsplat | ForEach-Object { $extensionsInUse.Add($_) }

        # Find the next free number in the ranges
        # Iterate over the ranges until a free number is found
        Write-Verbose "Finding next free number in ranges"
        foreach ($range in $ranges) {
            $nextFreeNumber = Get-TPNMNextFreeNumberByExtRange -ExtRange $range -ExtensionsInUse $extensionsInUse -EnableLeadingZero:$EnableLeadingZero
            if ($nextFreeNumber) { break }
        }

        # If no next free number is found, throw an error
        if (-not $nextFreeNumber) {
            throw 'No free number found. Please check the ranges and allocations.'
        }

        # Add the next free number to the allocation table as a new allocation with state 'Requested'
        Write-Verbose "Found next free number: $($nextFreeNumber.NumberShort)"
        $sqlQuery = @'
INSERT INTO Allocation (ExtRange, Extension, State, CreatedOn, Description) VALUES ({0}, '{1}', 'Requested', GETDATE(), '');
'@ -f $nextFreeNumber.ExtRangeId, $nextFreeNumber.Extension

        Write-Verbose "Executing the following SQL query: $sqlQuery."
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row to database table 'Allocation' with values ExtRangeId '$($nextFreeNumber.ExtRangeId)', Extension '$($nextFreeNumber.Extension)' and State 'Requested'", "Add")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # Get the allocation based on the next free number and return it
        $result = Get-TPNMAllocation -ExtRangeId $nextFreeNumber.ExtRangeId -AllocationExtension $nextFreeNumber.Extension
            
        # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
        Push-TPNMResultSet -ResultSet $result
    }
}