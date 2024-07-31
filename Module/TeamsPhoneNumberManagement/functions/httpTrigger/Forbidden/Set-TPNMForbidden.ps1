function Set-TPNMForbidden {
    <#
        .SYNOPSIS
        Updates a forbidden entry in the database.

        .DESCRIPTION
        The Set-TPNMForbidden function updates a forbidden entry in the database table 'Forbidden'.
        The forbidden entry is identified by its ID.
        The function can update the description of the forbidden entry.

        .PARAMETER ForbiddenId
        The ID of the forbidden entry.
        It should be a string with a maximum of 5 digits.

        .PARAMETER ForbiddenDescription
        The description of the forbidden entry.
        It should be a string with a maximum of 100 characters (including whitespace).

        .PARAMETER PassThru
        Switch parameter to return the updated forbidden entry.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Set-TPNMForbidden -ForbiddenId "12345" -ForbiddenDescription "Blocked for security reasons"

        This example updates the description of the forbidden entry with the ID "12345".

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Get-TPNMForbidden functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses confirmation by default before executing the database query.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Description')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Description')]
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $ForbiddenId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Description')]
        [ValidatePattern( '^[a-zA-Z0-9\s-_]{1,100}$', ErrorMessage = 'The description must be at maximum a 100 character string. It can contain letters, numbers, whitespace, and the characters "-" and "_"' )]
        [string]
        $ForbiddenDescription,

        [switch]
        $PassThru
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        if ($ForbiddenDescription) {
            $Column = 'Description'
            $Value = $ForbiddenDescription
        }

        # Query the database for the forbidden table
        $sqlQuery = @'
        UPDATE Forbidden SET {0}='{1}'
        WHERE ID='{2}';
'@ -f $Column, $Value, $ForbiddenId

        Write-Verbose "Updating the database for the forbidden table. Query: $sqlQuery"
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row with ID $ForbiddenId from database table 'Forbidden', setting $Column to '$Value'", "Set")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # If the PassThru switch is set, query the database for the updated forbidden and return it
        if ($PassThru) {
            $result = Get-TPNMForbidden -ForbiddenId $ForbiddenId
            
            # If needed, skip and limit the resultset
            # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
            Push-TPNMResultSet -ResultSet $result
        }
    }
}