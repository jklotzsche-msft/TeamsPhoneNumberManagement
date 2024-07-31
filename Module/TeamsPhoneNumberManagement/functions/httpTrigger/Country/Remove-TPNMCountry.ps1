function Remove-TPNMCountry {
    <#
        .SYNOPSIS
        Removes a country from the database.

        .DESCRIPTION
        The Remove-TPNMCountry function removes a country from the database table 'Country'.
        The country is identified by its ID.

        .PARAMETER CountryId
        The ID of the country.
        It should be a string with a maximum of 5 digits.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Remove-TPNMCountry -CountryId "123"

        This example removes the country with the ID "123" from the database.

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest function to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses confirmation by default before executing the database query.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $CountryId
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # Query the database for the country table
        $sqlQuery = @'
DELETE FROM Country
WHERE ID = {0};
'@ -f $CountryId

        Write-Verbose "Removing row $CountryId from database table country."
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row with ID $CountryId from database table 'Country'", "Remove")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }
    }
}