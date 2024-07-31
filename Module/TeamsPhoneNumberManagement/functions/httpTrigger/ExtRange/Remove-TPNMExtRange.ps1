function Remove-TPNMExtRange {
    <#
        .SYNOPSIS
        Removes an extension range from the database.

        .DESCRIPTION
        The Remove-TPNMExtRange function removes an extension range from the database table 'ExtRange'.
        The extension range is identified by its ID.

        .PARAMETER ExtRangeId
        The ID of the extension range.
        It should be a string with a maximum of 5 digits.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Remove-TPNMExtRange -ExtRangeId "123"
        
        This example removes the extension range with the ID "123" from the database.

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
        $ExtRangeId
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # Query the database for the ExtRange table
        $sqlQuery = @'
DELETE FROM ExtRange
WHERE ID = {0};
'@ -f $ExtRangeId

        Write-Verbose "Removing row $ExtRangeId from database table ExtRange."
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row with ID $ExtRangeId from database table 'ExtRange'", "Remove")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }
    }
}