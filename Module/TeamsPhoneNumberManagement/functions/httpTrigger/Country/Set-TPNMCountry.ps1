function Set-TPNMCountry {
    <#
        .SYNOPSIS
        Updates a country in the database.

        .DESCRIPTION
        The Set-TPNMCountry function updates a country in the database table 'Country'.
        A country record includes the country name, country code, and an optional description.

        .PARAMETER CountryId
        The ID of the country.
        It should be a string with a maximum of 5 digits.

        .PARAMETER CountryDescription
        The description of the country.
        It should be a string with a maximum of 100 characters (including whitespace).

        .PARAMETER PassThru
        Switch parameter to return the updated country.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Set-TPNMCountry -CountryId "123" -CountryDescription "United States of America"

        This example updates the description of the country with the ID "123".

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Get-TPNMCountry functions to be available.
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
        $CountryId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Description')]
        [ValidatePattern( '^[a-zA-Z0-9\s-_]{1,100}$', ErrorMessage = 'The description must be at maximum a 100 character string. It can contain letters, numbers, whitespace, and the characters "-" and "_"' )]
        [string]
        $CountryDescription,

        [switch]
        $PassThru
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        if ($CountryDescription) {
            $Column = 'Description'
            $Value = $CountryDescription
        }

        # Query the database for the country table
        $sqlQuery = @'
        UPDATE Country SET {0}='{1}'
        WHERE ID='{2}';
'@ -f $Column, $Value, $CountryId

        Write-Verbose "Updating the database for the country table. Query: $sqlQuery"
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row with ID $CountryId from database table 'Country', setting $Column to '$Value'", "Set")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # If the PassThru switch is set, query the database for the updated country and return it
        if ($PassThru) {
            $result = Get-TPNMCountry -CountryId $CountryId
            
            # If needed, skip and limit the resultset
            # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
            Push-TPNMResultSet -ResultSet $result
        }
    }
}