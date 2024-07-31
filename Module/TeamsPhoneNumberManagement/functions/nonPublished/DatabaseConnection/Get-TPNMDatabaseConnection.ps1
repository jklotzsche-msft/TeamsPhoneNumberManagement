function Get-TPNMDatabaseConnection {
    <#
        .SYNOPSIS
        Retrieves information about the current SQL database connection.

        .DESCRIPTION
        The Get-TPNMDatabaseConnection function returns a custom object containing details about the current SQL database connection.

        .EXAMPLE
        Get-TPNMDatabaseConnection

        This example retrieves information about the current SQL database connection, such as connection string, timeout, database name, data source, packet size, client connection ID, server version, state, and workstation ID.

        .NOTES
        - This function sets the error action preference to 'Stop' to ensure that any errors encountered will stop the function execution.
        - The function returns a custom object with properties representing various details of the SQL connection.

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
        Write-Verbose -Message "Returning a custom object representing the SqlConnection object."
        $sqlConnectionInformation = [PSCustomObject]@{
            'ConnectionString'   = $script:sqlConnection.ConnectionString
            'ConnectionTimeout'  = $script:sqlConnection.ConnectionTimeout
            'Database'           = $script:sqlConnection.Database
            'DataSource'         = $script:sqlConnection.DataSource
            'PacketSize'         = $script:sqlConnection.PacketSize
            'ClientConnectionId' = $script:sqlConnection.ClientConnectionId
            'ServerVersion'      = $script:sqlConnection.ServerVersion
            'State'              = $script:sqlConnection.State
            'WorkstationId'      = $script:sqlConnection.WorkstationId
        }
        $sqlConnectionInformation
    }
}