function Resume-TPNMDatabaseConnection {
    <#
        .SYNOPSIS
        Resumes the connection to the TPNM database.

        .DESCRIPTION
        The Resume-TPNMDatabaseConnection function ensures that the connection to the TPNM database is re-established. It first disconnects any existing connection and then reconnects to the specified SQL Server and database.

        .PARAMETER None
        This function does not take any parameters.

        .EXAMPLE
        Resume-TPNMDatabaseConnection

        This example resumes the connection to the TPNM database using the previously specified SQL Server and database names.

        .NOTES
        - This function sets the error action preference to 'Stop' to ensure that any errors encountered will stop the function execution.
        - The function checks if the SqlServerName and SqlDatabaseName script variables are set. If not, it throws an error.
        - The function disconnects from the current database connection using Disconnect-TPNMDatabase.
        - The function reconnects to the database using Connect-TPNMDatabase with the previously specified SQL Server and database names.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding()]
    param ()

    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # If the SqlServerName or SqlDatabaseName is not provided by a script variable, throw an error.
        if (-not ($script:SqlServerName -and $script:SqlDatabaseName)) {
            throw 'Please connect to a TPNM database first using Connect-TPNMDatabase.'
        }

        # Disconnect from the database
        Disconnect-TPNMDatabase

        # Connect to the database
        Write-Verbose "Reconnecting to the database $script:SqlDatabaseName on $script:SqlServerName."
        Connect-TPNMDatabase -SqlServerName $script:SqlServerName -SqlDatabaseName $script:SqlDatabaseName
    }
}