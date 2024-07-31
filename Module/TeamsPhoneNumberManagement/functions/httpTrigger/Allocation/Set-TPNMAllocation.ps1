function Set-TPNMAllocation {
    <#
        .SYNOPSIS
        Updates an existing allocation in the database.

        .DESCRIPTION
        The Set-TPNMAllocation function updates an existing allocation in the database table 'Allocation'.
        It allows updating either the state or the description of the allocation based on the provided parameters.

        .PARAMETER AllocationId
        The ID of the allocation to update.
        It should be a string with a maximum of 5 digits.

        .PARAMETER AllocationState
        The state of the allocation.
        It should be a valid value from the TPNMAllocationState enum.

        .PARAMETER AllocationDescription
        The description of the allocation.
        It should be a string with a maximum of 100 characters (including whitespace).

        .PARAMETER PassThru
        Switch parameter to return the updated allocation.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Set-TPNMAllocation -AllocationId "12345" -AllocationState "Active"

        This example updates the state of the allocation with ID 12345 to "Active".

        .EXAMPLE
        Set-TPNMAllocation -AllocationId "12345" -AllocationDescription "Updated Description"

        This example updates the description of the allocation with ID 12345 to "Updated Description".

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Get-TPNMAllocation functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses confirmation by default before executing the database query.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Description')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Description')]
        [Parameter(Mandatory = $true, ParameterSetName = 'State')]
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $AllocationId,

        [Parameter(Mandatory = $true, ParameterSetName = 'State')]
        [TPNMAllocationState]
        $AllocationState,

        [Parameter(Mandatory = $true, ParameterSetName = 'Description')]
        [ValidatePattern( '^[a-zA-Z0-9\s-_]{1,100}$', ErrorMessage = 'The description must be at maximum a 100 character string. It can contain letters, numbers, whitespace, and the characters "-" and "_"' )]
        [string]
        $AllocationDescription,

        [switch]
        $PassThru
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        if ($AllocationState) {
            $Column = 'State'
            $Value = $AllocationState
        }

        if ($AllocationDescription) {
            $Column = 'Description'
            $Value = $AllocationDescription
        }

        # Query the database for the allocation table
        $sqlQuery = @'
        UPDATE Allocation SET {0}='{1}'
        WHERE ID='{2}';
'@ -f $Column, $Value, $AllocationId

        Write-Verbose "Updating the database for the allocation table. Query: $sqlQuery"
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row with ID $AllocationId from database table 'Allocation', setting $Column to '$Value'", "Set")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # If the PassThru switch is set, query the database for the updated allocation and return it
        if ($PassThru) {
            $result = Get-TPNMAllocation -AllocationId $AllocationId
            
            # If needed, skip and limit the resultset
            # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
            Push-TPNMResultSet -ResultSet $result
        }
    }
}