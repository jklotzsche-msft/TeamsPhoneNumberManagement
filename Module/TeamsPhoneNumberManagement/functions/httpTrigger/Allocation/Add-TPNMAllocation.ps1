function Add-TPNMAllocation {
    <#
        .SYNOPSIS
        Adds a new allocation to the database.

        .DESCRIPTION
        The Add-TPNMAllocation function adds a new allocation to the database table 'Allocation'.
        An Allocation is a record that is used to allocate a specific extension to a specific extension range.

        .PARAMETER ExtRangeId
        The ID of the extension range.
        It should be a string with a maximum of 5 digits.

        .PARAMETER AllocationExtension
        The extension to allocate.
        It should be a string with a maximum of 15 digits.

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
        Add-TPNMAllocation -ExtRangeId "12345" -AllocationExtension "987654321" -AllocationState "Active" -AllocationDescription "Sales Department"

        This example adds a new allocation to the database with the specified parameters.

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Get-TPNMAllocation functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses confirmation by default before executing the database query.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $ExtRangeId,

        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\d{1,15}$', ErrorMessage = 'This must be a 15 digit number.' )]
        [string]
        $AllocationExtension,

        [Parameter(Mandatory = $true)]
        [TPNMAllocationState]
        $AllocationState,

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
        # Query the database for the allocation table
        $sqlQuery = @'
        INSERT INTO Allocation (ExtRange, Extension, State, CreatedOn, Description) VALUES ('{0}', '{1}', '{2}', GETDATE(), '{3}');
'@ -f $ExtRangeId, $AllocationExtension, $AllocationState, $AllocationDescription

        Write-Verbose "Adding row to the database in the allocation table. Query: $sqlQuery"
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row to database table 'Allocation' with values ExtRange '$ExtRangeId', Extension '$AllocationExtension', State '$AllocationState' and Description '$AllocationDescription'", "Add")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # If the PassThru switch is set, query the database for the updated allocation and return it
        if ($PassThru) {
            $result = Get-TPNMAllocation -ExtRangeId $ExtRangeId -AllocationExtension $AllocationExtension
            
            # If needed, skip and limit the resultset
            # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
            Push-TPNMResultSet -ResultSet $result
        }
    }
}