function Get-TPNMCountry {
    <#
        .SYNOPSIS
        Retrieves country information from the database.

        .DESCRIPTION
        The Get-TPNMCountry function retrieves country information from the 'Country' table in the database.
        It allows filtering by CountryId, CountryName, and CountryCode, and supports pagination through ResultSize and Skip parameters.

        .PARAMETER CountryId
        The ID of the country.
        It should be a string with a maximum of 5 digits.

        .PARAMETER CountryName
        The name of the country.
        It should be a two-letter, uppercase string.

        .PARAMETER CountryCode
        The country code.
        It should be a plus character followed by a maximum of four digits.

        .PARAMETER ResultSize
        The maximum number of results to return.
        It should be a positive integer value or the string 'unlimited'.
        The default value is 100.

        .PARAMETER Skip
        The number of results to skip.
        It should be zero or a positive integer value.
        The default value is 0.

        .EXAMPLE
        Get-TPNMCountry -CountryId "123"

        This example retrieves country information for the country with ID "123".

        .EXAMPLE
        Get-TPNMCountry -CountryName "US"

        This example retrieves country information for the country with the name "US".

        .EXAMPLE
        Get-TPNMCountry -CountryCode "+1"

        This example retrieves country information for the country with the code "+1".

        .EXAMPLE
        Get-TPNMCountry -ResultSize 10 -Skip 5

        This example retrieves the fifth to fifteenth country information.

        .NOTES
        - This function requires the Optimize-TPNMSqlQueryFilter, Invoke-TPNMSqlRequest, and Push-TPNMResultSet functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function constructs and executes an SQL query to retrieve the country information and handles pagination.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding()]
    param (
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $CountryId,

        [ValidatePattern( '^[A-Z]{2}$', ErrorMessage = 'The Country Name must be a two-letter, uppercase string' )]
        [string]
        $CountryName,

        [ValidatePattern( '^\+\d{1,4}$', ErrorMessage = 'The country code must be a plus character followed by maximum four digits.' )]
        [string]
        $CountryCode,

        [ValidateScript({
                if ($_ -is [int] -and $_ -ge 1) { $true }
                elseif ($_ -eq "unlimited") { $true }
                else { throw "ResultSize must be a positive integer value or the string 'unlimited'." }
            })]
        [Object]
        $ResultSize = 100,

        [ValidateScript({
                if ($_ -is [int] -and $_ -ge 0) { $true }
                else { throw "Skip must be zero or a positive integer value." }
            })]
        [int]
        $Skip = 0
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # Prepare resultset
        $resultSet = [System.Collections.Generic.List[pscustomobject]]::new()

        # Query the database for the country table
        $sqlQuery = @'
SELECT
    ID AS CountryId,
    Code AS CountryCode,
    Name AS CountryName,
    Description AS CountryDescription
FROM
    Country;
'@

        # Add one or multiple where clauses to the SQL query, depending on the provided parameters
        $sqlQuery = Optimize-TPNMSqlQueryFilter -SqlQuery $sqlQuery -PassedParameter ($PSBoundParameters.GetEnumerator())

        # Invoke the SQL query and add the result to the resultset
        Write-Verbose "Executing the following SQL query:`n$sqlQuery"
        Invoke-TPNMSqlRequest -SqlQuery $sqlQuery | ForEach-Object -Process {
            $resultSet.Add([PSCustomObject]$_)
        }
        Write-Verbose "Found $($resultSet.Count) entries."

        # If no country is found, stop the function and return a warning
        if ($resultSet.Count -eq 0) {
            Write-Warning -Message 'No country found.'
            return
        }

        # If needed, skip and limit the resultset
        # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
        Push-TPNMResultSet -ResultSet $resultSet -ResultSize $ResultSize -Skip $Skip
    }
}