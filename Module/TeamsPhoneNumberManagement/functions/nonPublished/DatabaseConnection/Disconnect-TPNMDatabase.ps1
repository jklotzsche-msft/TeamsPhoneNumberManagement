function Disconnect-TPNMDatabase {
    <#
        .SYNOPSIS
        Disconnects from the TPNM database.

        .DESCRIPTION
        The Disconnect-TPNMDatabase function closes the existing SQL database connection and removes the SqlConnection object from the script scope.

        .EXAMPLE
        Disconnect-TPNMDatabase

        This example disconnects from the TPNM database by closing the connection and removing the SqlConnection object.

        .NOTES
        - This function sets the error action preference to 'Stop' to ensure that any errors encountered will stop the function execution.
        - The function checks if the SQL connection is open before attempting to close it.
        - The SqlConnection object is set to $null after closing the connection to remove it from the script scope.

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
        # Close the connection
        if ($script:sqlConnection.State -eq "Open") {
            Write-Verbose "Closing the connection."
            $script:sqlConnection.Close()
        }

        # Remove the SqlConnection object
        Write-Verbose "Removing the SqlConnection object."
        $script:sqlConnection = $null
    }
}