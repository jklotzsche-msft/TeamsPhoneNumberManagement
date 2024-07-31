function Connect-TPNMDatabase {
    <#
        .SYNOPSIS
        Connects to an Azure SQL Database using the provided server and database names.

        .DESCRIPTION
        The Connect-TPNMDatabase function establishes a connection to an Azure SQL Database.
        It retrieves an access token from Azure and uses it to authenticate the connection.
        The connection details are stored in the script scope for use by other functions in the script.

        .PARAMETER SqlServerName
        The name of the SQL Server.
        It defaults to the value of the environment variable 'SqlServerName' if not provided.

        .PARAMETER SqlDatabaseName
        The name of the SQL Database.
        It defaults to the value of the environment variable 'SqlDatabaseName' if not provided.

        .EXAMPLE
        Connect-TPNMDatabase -SqlServerName "myServer" -SqlDatabaseName "myDatabase"

        This example connects to the Azure SQL Database 'myDatabase' on the server 'myServer'.

        .EXAMPLE
        Connect-TPNMDatabase

        This example connects to the Azure SQL Database using the server and database names specified in the environment variables 'SqlServerName' and 'SqlDatabaseName'.

        .NOTES
        - This function requires the Azure PowerShell module to be installed and the user to be authenticated with Azure.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function retrieves an access token for the Azure SQL Database and uses it to authenticate the connection.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding()]
    param (
        [string]
        $SqlServerName = $env:SqlServerName,

        [string]
        $SqlDatabaseName = $env:SqlDatabaseName
    )

    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # Check, if we are connected to Azure
        $azContext = Get-AzContext -ErrorAction SilentlyContinue
        if (-not $azContext) {
            throw 'You must be connected to Azure to use this function. Please connect to Azure using Connect-AzAccount.'
        }

        # Get the token for the Azure SQL Database
        Write-Verbose "Getting token from ResourceUrl 'https://database.windows.net/'."
        $sqlToken = Get-AzAccessToken -ResourceUrl 'https://database.windows.net/'

        # Create a new SqlConnection object
        # This variable is defined in the script scope, so it can be used by other functions of this script
        Write-Verbose "Creating a new SqlConnection object."
        $script:sqlConnection = New-Object -TypeName 'System.Data.SqlClient.SqlConnection'

        # Set the AccessToken and ConnectionString properties
        Write-Verbose "Setting the AccessToken and ConnectionString properties."
        $sqlConnection.AccessToken = $sqlToken.Token
        $sqlConnection.ConnectionString = 'Server={0}.database.windows.net;Initial Catalog={1};Encrypt=True;TrustServerCertificate=True;' -f $SqlServerName, $SqlDatabaseName

        # Open the connection
        Write-Verbose "Opening the connection."
        $sqlConnection.Open()

        # If we reach this point, the connection was successful and we can store the DatabaseName and ServerName in the script scope
        $script:sqlServerName = $SqlServerName
        $script:sqlDatabaseName = $SqlDatabaseName
    }
}