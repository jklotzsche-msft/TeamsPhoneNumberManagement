function Get-TPNMForbidden {
    <#
        .SYNOPSIS
        Retrieves forbidden extensions from the database.

        .DESCRIPTION
        The Get-TPNMForbidden function retrieves forbidden extensions from the database table 'Forbidden'.
        It joins the 'Forbidden' table with the 'Country' table to provide detailed information about each forbidden extension.

        .PARAMETER CountryId
        The ID of the country.
        It should be a string with a maximum of 5 digits.

        .PARAMETER CountryName
        The name of the country.
        It should be a two-letter, uppercase string.

        .PARAMETER CountryCode
        The country code.
        It should be a plus character followed by a maximum of four digits.

        .PARAMETER ForbiddenId
        The ID of the forbidden extension.
        It should be a string with a maximum of 5 digits.

        .PARAMETER ForbiddenExtension
        The forbidden extension.
        It should be a string with a maximum of 15 digits.

        .PARAMETER ResultSize
        The maximum number of results to return.
        It should be a positive integer value or the string 'unlimited'.
        The default value is 100.

        .PARAMETER Skip
        The number of results to skip.
        It should be zero or a positive integer value.
        The default value is 0.

        .EXAMPLE
        Get-TPNMForbidden -CountryId "123"

        This example retrieves all forbidden extensions for the country with ID 123.

        .EXAMPLE
        Get-TPNMForbidden -CountryName "US"

        This example retrieves all forbidden extensions for the country with the name "US".

        .EXAMPLE
        Get-TPNMForbidden -CountryCode "+1"

        This example retrieves all forbidden extensions for the country with the code "+1".

        .EXAMPLE
        Get-TPNMForbidden -ForbiddenId "12345"

        This example retrieves the forbidden extension with the ID 12345.

        .EXAMPLE
        Get-TPNMForbidden -ForbiddenExtension "987654321"

        This example retrieves the forbidden extension with the extension "987654321".

        .EXAMPLE
        Get-TPNMForbidden -ResultSize 10 -Skip 5

        This example retrieves the fifth to fifteenth forbidden extensions.

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Optimize-TPNMSqlQueryFilter functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses verbose output to display the executed SQL query and the number of entries found.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
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

        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $ForbiddenId,

        [ValidatePattern( '^\d{1,15}$', ErrorMessage = 'This must be a 15 digit number.' )]
        [string]
        $ForbiddenExtension,

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

        # Query the database for the forbidden table
        $sqlQuery = @'
SELECT
    Forbidden.ID AS ForbiddenId,
    Forbidden.Extension AS ForbiddenExtension,
    Forbidden.Description AS ForbiddenDescription,
    Country.ID AS CountryId,
    Country.Code AS CountryCode,
    Country.Name AS CountryName
FROM
    Forbidden
JOIN
    Country ON Forbidden.Country = Country.ID;
'@

        # Add one or multiple where clauses to the SQL query, depending on the provided parameters
        $sqlQuery = Optimize-TPNMSqlQueryFilter -SqlQuery $sqlQuery -PassedParameter ($PSBoundParameters.GetEnumerator())

        # Invoke the SQL query and add the result to the resultset
        Write-Verbose "Executing the following SQL query:`n$sqlQuery"
        Invoke-TPNMSqlRequest -SqlQuery $sqlQuery | ForEach-Object -Process {
            $resultSet.Add([PSCustomObject]$_)
        }
        Write-Verbose "Found $($resultSet.Count) entries."

        # If no forbidden extension is found, stop the function and return a warning
        if ($resultSet.Count -eq 0) {
            Write-Warning -Message 'No forbidden extension found.'
            return
        }

        # If needed, skip and limit the resultset
        # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
        Push-TPNMResultSet -ResultSet $resultSet -ResultSize $ResultSize -Skip $Skip
    }
}