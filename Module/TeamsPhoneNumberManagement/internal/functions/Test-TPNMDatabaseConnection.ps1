function Test-TPNMDatabaseConnection {
    <#
        .SYNOPSIS
        Tests the connection to the TPNM database.

        .DESCRIPTION
        The Test-TPNMDatabaseConnection function verifies that a connection to the TPNM database can be established. It attempts to connect to the specified SQL Server and database and returns a boolean indicating the success or failure of the connection attempt.

        .PARAMETER None
        This function does not take any parameters.

        .EXAMPLE
        $isConnected = Test-TPNMDatabaseConnection

        This example tests the connection to the TPNM database and stores the result in the $isConnected variable.

        .NOTES
        - This function sets the error action preference to 'Stop' to ensure that any errors encountered will stop the function execution.
        - The function checks if the SqlServerName and SqlDatabaseName script variables are set. If not, it throws an error.
        - The function attempts to connect to the database using Connect-TPNMDatabase.
        - The function returns $true if the connection is successful, and $false otherwise.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # If the connection object is not found, return false
        if ($null -eq $script:sqlConnection) {
            Write-Warning -Message 'No connection object found. Please connect to a TPNM database first using Connect-TPNMDatabase.'
            return $false
        }

        # If the connection is not open, try to open it
        if ($script:sqlConnection.State -ne "Open") {
            Write-Verbose -Message 'The sql connection exists but is not open. Trying to open the connection.'
            try {
                $script:sqlConnection.Open()
            }
            catch {
                Write-Warning -Message 'The sql connection cannot be opened. Trying to reconnect to the TPNM database using Resume-TPNMDatabaseConnection.'
                Resume-TPNMDatabaseConnection
            }

            if ($script:sqlConnection.State -ne "Open") {
                Write-Error -Message 'Cannot reconnect to the TPNM database.'
                return $false
            }
        }

        # If the connection is open, return true
        return $true
    }
}