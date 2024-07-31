function Remove-TPNMForbidden {
    <#
        .SYNOPSIS
        Removes a forbidden entry from the database.

        .DESCRIPTION
        The Remove-TPNMForbidden function removes a forbidden entry from the database table 'Forbidden'.
        The forbidden entry is identified by its ID.

        .PARAMETER ForbiddenId
        The ID of the forbidden entry.
        It should be a string with a maximum of 5 digits.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Remove-TPNMForbidden -ForbiddenId "12345"
        
        This example removes the forbidden entry with the ID "12345" from the database.

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
        $ForbiddenId
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # Query the database for the Forbidden table
        $sqlQuery = @'
DELETE FROM Forbidden
WHERE ID = {0};
'@ -f $ForbiddenId

        Write-Verbose "Removing row $ForbiddenId from database table Forbidden."
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row with ID $ForbiddenId from database table 'Forbidden'", "Remove")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }
    }
}