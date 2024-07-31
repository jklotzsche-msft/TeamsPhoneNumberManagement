function Remove-TPNMAllocation {
    <#
        .SYNOPSIS
        Removes an allocation from the database.

        .DESCRIPTION
        The Remove-TPNMAllocation function removes an existing allocation from the database table 'Allocation'.
        An Allocation is a record that is used to allocate a specific extension to a specific extension range.

        .PARAMETER AllocationId
        The ID of the allocation to remove.
        It should be a string with a maximum of 5 digits.

        .PARAMETER Confirm
        Switch parameter to prompt for confirmation before removing the allocation.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Remove-TPNMAllocation -AllocationId "12345" -Confirm

        This example removes the allocation with the specified AllocationId from the database, prompting for confirmation before executing the removal.

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest function to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses confirmation by default before executing the database query.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $AllocationId
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # Query the database for the allocation table
        $sqlQuery = @'
DELETE FROM Allocation
WHERE ID = {0};
'@ -f $AllocationId

        Write-Verbose "Removing row $AllocationId from database table allocation."
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row with ID $AllocationId from database table 'Allocation'", "Remove")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }
    }
}