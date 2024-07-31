function Invoke-TPNMSqlRequest {
    <#
        .SYNOPSIS
        Executes a SQL query and returns the results as PowerShell custom objects.

        .DESCRIPTION
        The Invoke-TPNMSqlRequest function executes a provided SQL query against the current SQL database connection and returns the results as PowerShell custom objects. It ensures that the database connection is active before executing the query.

        .PARAMETER SqlQuery
        The SQL query to be executed.

        .EXAMPLE
        $query = "SELECT * FROM Users"
        $results = Invoke-TPNMSqlRequest -SqlQuery $query

        This example executes a SQL query to select all records from the Users table and returns the results as PowerShell custom objects.

        .NOTES
        - This function sets the error action preference to 'Stop' to ensure that any errors encountered will stop the function execution.
        - The function checks if the database connection is active using the Test-TPNMDatabaseConnection function.
        - The function creates a new SqlCommand object, sets its CommandText property, and executes the command.
        - The results are returned as PowerShell custom objects with properties corresponding to the columns in the result set.
        - The SqlDataReader is closed in the finally block to ensure proper resource cleanup.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $SqlQuery
    )
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # Test if we are connected to the database
        if (-not (Test-TPNMDatabaseConnection)) {
            # Stop the function if we are not connected to the database
            # Write-Error -Message "You are not connected or could not reconnect to the database. Please connect to the database using Connect-TPNMDatabase."
            # return
            throw "You are not connected or could not reconnect to the database. Please connect to the database using Connect-TPNMDatabase."
        }

        Write-Verbose "Creating a new SqlCommand object."
        $command = $script:SqlConnection.CreateCommand()

        Write-Verbose "Setting the CommandText property."
        $command.CommandText = $SqlQuery

        try {
            Write-Verbose "Executing the command."
            $results = $command.ExecuteReader()

            foreach ($item in $results) {
                $hash = [ordered]@{}

                foreach ($number in 0..($item.FieldCount - 1)) {
                    $hash[$item.GetName($number)] = $item.GetValue($number)
                }

                [pscustomobject]$hash
            }
        }
        finally {
            # Keeping the SqlDataReader open for further processing
            Write-Verbose "Closing the SqlDataReader."
            $script:sqlConnection.Close()
        }
    }
}