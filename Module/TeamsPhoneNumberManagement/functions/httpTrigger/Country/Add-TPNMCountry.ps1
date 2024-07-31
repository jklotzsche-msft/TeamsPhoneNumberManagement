function Add-TPNMCountry {
    <#
        .SYNOPSIS
        Adds a new country to the database.

        .DESCRIPTION
        The Add-TPNMCountry function adds a new country to the database table 'Country'.
        A country record includes the country name, country code, and an optional description.

        .PARAMETER CountryName
        The name of the country.
        It should be a two-letter, uppercase string (ISO 3166-1 alpha-2).

        .PARAMETER CountryCode
        The code of the country.
        It should be a plus character followed by a maximum of four digits (E.164).

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
        Add-TPNMCountry -CountryName "US" -CountryCode "+1" -CountryDescription "United States of America"

        This example adds a new country to the database with the specified parameters.

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Get-TPNMCountry functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses confirmation by default before executing the database query.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^[A-Z]{2}$', ErrorMessage = 'The Country Name must be a two-letter, uppercase string' )]
        [string]
        $CountryName,

        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\+\d{1,4}$', ErrorMessage = 'The country code must be a plus character followed by maximum four digits.' )]
        [string]
        $CountryCode,

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
        # Query the database for the country table
        $sqlQuery = @'
        INSERT INTO Country (Name, Code, Description) VALUES ('{0}', '{1}', '{2}');
'@ -f $CountryName, $CountryCode, $CountryDescription

        Write-Verbose "Adding row to the database in the country table. Query: $sqlQuery"
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row to database table 'Country' with values CountryName '$CountryName', CountryCode '$CountryCode' and Description '$CountryDescription'", "Add")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # If the PassThru switch is set, query the database for the updated country and return it
        if ($PassThru) {
            $result = Get-TPNMCountry -CountryName $CountryName
            
            # If needed, skip and limit the resultset
            # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
            Push-TPNMResultSet -ResultSet $result
        }
    }
}