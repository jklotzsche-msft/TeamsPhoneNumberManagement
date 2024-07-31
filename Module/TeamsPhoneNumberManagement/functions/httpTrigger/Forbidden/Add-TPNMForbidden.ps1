function Add-TPNMForbidden {
    <#
        .SYNOPSIS
        Adds a new forbidden entry to the database.

        .DESCRIPTION
        The Add-TPNMForbidden function adds a new forbidden entry to the database table 'Forbidden'.
        A forbidden entry is a record that specifies a country and an extension that are forbidden for use.

        .PARAMETER CountryId
        The ID of the country.
        It should be a string with a maximum of 5 digits.

        .PARAMETER ForbiddenExtension
        The forbidden extension.
        It should be a string with a maximum of 15 digits.

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
        Add-TPNMForbidden -CountryId "12345" -ForbiddenExtension "987654321" -ForbiddenDescription "Blocked for security reasons"

        This example adds a new forbidden entry to the database with the specified parameters.

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Get-TPNMForbidden functions to be available.
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
        $CountryId,

        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\d{1,15}$', ErrorMessage = 'This must be a 15 digit number.' )]
        [string]
        $ForbiddenExtension,

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
        # Query the database for the forbidden table
        $sqlQuery = @'
        INSERT INTO Forbidden (Country, Extension, Description) VALUES ('{0}', '{1}', '{2}');
'@ -f $CountryId, $ForbiddenExtension, $ForbiddenDescription

        Write-Verbose "Adding row to the database in the forbidden table. Query: $sqlQuery"
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row to database table 'Forbidden' with values Country '$CountryId', Extension '$ForbiddenExtension' and Description '$ForbiddenDescription'", "Add")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # If the PassThru switch is set, query the database for the updated forbidden and return it
        if ($PassThru) {
            $result = Get-TPNMForbidden -CountryId $CountryId -ForbiddenExtension $ForbiddenExtension
            
            # If needed, skip and limit the resultset
            # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
            Push-TPNMResultSet -ResultSet $result
        }
    }
}