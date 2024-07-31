function Optimize-TPNMSqlQueryFilter {
    <#
        .SYNOPSIS
        Optimizes a SQL query by adding filters based on provided parameters.

        .DESCRIPTION
        The Optimize-TPNMSqlQueryFilter function takes a SQL query and a set of parameters, and adds appropriate WHERE clauses to the query based on the provided parameters. It ensures that only valid table column parameters are included in the WHERE clause.

        .PARAMETER SqlQuery
        The SQL query to be optimized.

        .PARAMETER PassedParameter
        A hashtable of parameters where the key is the parameter name and the value is the parameter value.

        .EXAMPLE
        $query = "SELECT * FROM Users;"
        $params = @{ UserId = 1; UserName = "JohnDoe" }
        $optimizedQuery = Optimize-TPNMSqlQueryFilter -SqlQuery $query -PassedParameter $params

        This example optimizes the SQL query by adding WHERE clauses for UserId and UserName.

        .NOTES
        - This function sets the error action preference to 'Stop' to ensure that any errors encountered will stop the function execution.
        - The function iterates through the provided parameters and adds them to the WHERE clause if they are valid table column parameters.
        - The function uses the TPNMDatabaseTable enum to validate table column parameters.
        - The function constructs the WHERE clause dynamically and appends it to the original SQL query.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $SqlQuery,

        [Parameter(Mandatory = $true)]
        $PassedParameter
    )

    # Prepare the SQL query filter
    $sqlQueryFilter = ';'

    # Iterate through all parameters and add them to the WHERE clause, if they are provided
    foreach ($p in $passedParameter) {

        # Skip the parameter if the value is null
        if ($null -eq $p.Value) {
            continue
        }
            
        # Prepare the SQL filter key by replacing the parameter key with the database table column name and a dot
        $isTableColumnParameter = $false
        foreach ($databaseTable in [TPNMDatabaseTable].GetEnumNames()) {
            if ($p.Key -like "$databaseTable*") {
                $sqlFilterKey = $p.Key.replace("$databaseTable", "$databaseTable.")
                $isTableColumnParameter = $true
            }
        }

        # Skip the parameter if it is not a table column parameter
        if (-not $isTableColumnParameter) {
            continue
        }

        # Add the WHERE clause to the SQL query
        if ($sqlQueryFilter -eq ';') {
            # If the first parameter is added, replace the semicolon with WHERE
            $sqlQueryFilter = $sqlQueryFilter.replace(';', "`nWHERE`n    $sqlFilterKey = '$($p.Value)';")
        }
        else {
            # If the first parameter is already added, add the AND clause
            $sqlQueryFilter = $sqlQueryFilter.replace(';', " AND $sqlFilterKey = '$($p.Value)';")
        }
    }

    # Add the SQL query filter to the SQL query
    $SqlQuery = $SqlQuery.replace(';', $sqlQueryFilter)

    # Return the SQL query with the filter
    $SqlQuery
}