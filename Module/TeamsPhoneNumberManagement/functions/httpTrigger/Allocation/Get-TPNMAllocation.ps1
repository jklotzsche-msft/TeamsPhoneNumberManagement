﻿function Get-TPNMAllocation {
    <#
        .SYNOPSIS
        Retrieves allocation data from the database.

        .DESCRIPTION
        The Get-TPNMAllocation function retrieves allocation data from the database table 'Allocation'.
        It joins the Allocation table with ExtRange, Department, and Country tables to provide detailed information about each allocation.

        .PARAMETER CountryId
        The ID of the country.
        It should be a string with a maximum of 5 digits.

        .PARAMETER CountryName
        The name of the country.
        It should be a two-letter uppercase string (ISO 3166-1 alpha-2).

        .PARAMETER CountryCode
        The country code.
        It should be a string with a plus sign and a maximum of four digits (E.164).

        .PARAMETER DepartmentId
        The ID of the department.
        It should be a string with a maximum of 5 digits.

        .PARAMETER DepartmentName
        The name of the department.
        It should be a string with a maximum of 15 characters.

        .PARAMETER ExtRangeId
        The ID of the extension range.
        It should be a string with a maximum of 5 digits.

        .PARAMETER ExtRangeSpan
        The span of the extension range.
        It should be a string with a maximum of 15 characters.

        .PARAMETER AllocationId
        The ID of the allocation.
        It should be a string with a maximum of 5 digits.

        .PARAMETER AllocationExtension
        The extension of the allocation.
        It should be a string with a maximum of 15 digits.

        .PARAMETER AllocationState
        The state of the allocation.
        It should be a valid value from the TPNMAllocationState enum.

        .PARAMETER ResultSize
        The maximum number of results to return.
        It should be a positive integer or the string 'unlimited'. Default is 100.

        .PARAMETER Skip
        The number of results to skip.
        It should be zero or a positive integer. Default is 0.

        .EXAMPLE
        Get-TPNMAllocation -CountryId "123" -DepartmentName "Sales"

        This example retrieves allocation data for the country with ID "123" and the department named "Sales".

        .EXAMPLE
        Get-TPNMAllocation -CountryName "US"

        This example retrieves allocation data for the country with the name "US".

        .EXAMPLE
        Get-TPNMAllocation -CountryCode "+1"

        This example retrieves allocation data for the country with the code "+1".

        .EXAMPLE
        Get-TPNMAllocation -AllocationId "12345"

        This example retrieves the allocation with the ID "12345".

        .EXAMPLE
        Get-TPNMAllocation -ResultSize 10 -Skip 5

        This example retrieves the fifth to fifteenth allocation data.

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Optimize-TPNMSqlQueryFilter functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses verbose output to provide detailed information about the SQL query execution.

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

        [ValidatePattern( '^\+\d{1,4}$', ErrorMessage = 'The country code must be a plus character followed by maximum three digits.' )]
        [string]
        $CountryCode,

        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $DepartmentId,

        [ValidatePattern( '^\w{1,15}$', ErrorMessage = 'The department name must be at maximum a 15 character string.' )]
        [string]
        $DepartmentName,

        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $ExtRangeId,

        [ValidatePattern( '^\d{1,15}$', ErrorMessage = 'This must be a 15 digit number.' )]
        [string]
        $ExtRangeSpan,

        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $AllocationId,

        [ValidatePattern( '^\d{1,15}$', ErrorMessage = 'This must be a 15 digit number.' )]
        [string]
        $AllocationExtension,

        [TPNMAllocationState]
        $AllocationState,

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

        # Query the database for the allocation table
        $sqlQuery = @'
SELECT
    Allocation.ID AS AllocationId,
    Allocation.Extension AS AllocationExtension,
    Allocation.State AS AllocationState,
    Allocation.CreatedOn AS AllocationCreatedOn,
    Allocation.Description AS AllocationDescription,
    ExtRange.ID AS ExtRangeId,
    ExtRange.Span AS ExtRangeSpan,
    ExtRange.SpanStart AS ExtRangeSpanStart,
    ExtRange.SpanEnd AS ExtRangeSpanEnd,
    Department.ID AS DepartmentId,
    Department.Name AS DepartmentName,
    Country.ID AS CountryId,
    Country.Code AS CountryCode,
    Country.Name AS CountryName
FROM
    Allocation
JOIN
    ExtRange ON Allocation.ExtRange = ExtRange.ID
JOIN
    Department ON ExtRange.Department = Department.ID
JOIN
    Country ON Department.Country = Country.ID;
'@

        # Add one or multiple where clauses to the SQL query, depending on the provided parameters
        $sqlQuery = Optimize-TPNMSqlQueryFilter -SqlQuery $sqlQuery -PassedParameter ($PSBoundParameters.GetEnumerator())

        # Invoke the SQL query and add the result to the resultset
        Write-Verbose "Executing the following SQL query:`n$sqlQuery"
        Invoke-TPNMSqlRequest -SqlQuery $sqlQuery | ForEach-Object -Process {
            $resultSet.Add([PSCustomObject]$_)
        }
        Write-Verbose "Found $($resultSet.Count) entries."

        # If no allocation is found, stop the function and return a warning
        if ($resultSet.Count -eq 0) {
            Write-Warning -Message 'No allocation found.'
            return
        }

        # If needed, skip and limit the resultset
        # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
        Push-TPNMResultSet -ResultSet $resultSet -ResultSize $ResultSize -Skip $Skip
    }
}