function Set-TPNMExtRange {
    <#
        .SYNOPSIS
        Sets the description of an extension range in the database.

        .DESCRIPTION
        The Set-TPNMExtRange function sets the description of an extension range in the database table 'ExtRange'.
        The extension range is identified by its ID.

        .PARAMETER ExtRangeId
        The ID of the extension range.
        It should be a string with a maximum of 5 digits.

        .PARAMETER ExtRangeDescription
        The description of the extension range.
        It should be a string with a maximum of 100 characters (including whitespace).

        .PARAMETER PassThru
        Switch parameter to return the updated extension range.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Set-TPNMExtRange -ExtRangeId "123" -ExtRangeDescription "New description"
        
        This example sets the description of the extension range with the ID "123" to "New description".

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Get-TPNMExtRange functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses confirmation by default before executing the database query.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Description')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Description')]
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $ExtRangeId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Description')]
        [ValidatePattern( '^[a-zA-Z0-9\s-_]{1,100}$', ErrorMessage = 'The description must be at maximum a 100 character string. It can contain letters, numbers, whitespace, and the characters "-" and "_"' )]
        [string]
        $ExtRangeDescription,

        [switch]
        $PassThru
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        if ($ExtRangeDescription) {
            $Column = 'Description'
            $Value = $ExtRangeDescription
        }

        # Query the database for the extrange table
        $sqlQuery = @'
        UPDATE ExtRange SET {0}='{1}'
        WHERE ID='{2}';
'@ -f $Column, $Value, $ExtRangeId

        Write-Verbose "Updating the database for the extrange table. Query: $sqlQuery"
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row with ID $ExtRangeId from database table 'ExtRange', setting $Column to '$Value'", "Set")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # If the PassThru switch is set, query the database for the updated extrange and return it
        if ($PassThru) {
            $result = Get-TPNMExtRange -ExtRangeId $ExtRangeId
            
            # If needed, skip and limit the resultset
            # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
            Push-TPNMResultSet -ResultSet $result
        }
    }
}