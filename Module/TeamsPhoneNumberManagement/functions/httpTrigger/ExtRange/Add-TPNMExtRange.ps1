function Add-TPNMExtRange {
    <#
        .SYNOPSIS
        Adds a new extension range to the database.

        .DESCRIPTION
        The Add-TPNMExtRange function adds a new extension range to the database table 'ExtRange'.
        An extension range record includes the department id, span, span start, span end, and an optional description.

        .PARAMETER DepartmentId
        The ID of the department.
        It should be a string with a maximum of 5 digits.

        .PARAMETER ExtRangeSpan
        The span of the extension range.
        It should be a string with a maximum of 15 digits.

        .PARAMETER ExtRangeSpanStart
        The start of the extension range.
        It should be a string with a maximum of 15 digits.

        .PARAMETER ExtRangeSpanEnd
        The end of the extension range.
        It should be a string with a maximum of 15 digits.

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
        Add-TPNMExtRange -DepartmentId "12345" -ExtRangeSpan "987654321" -ExtRangeSpanStart "987654321" -ExtRangeSpanEnd "987654321"

        This example adds a new extension range to the database with the specified parameters.

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Get-TPNMExtRange functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses confirmation by default before executing the database query.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $DepartmentId,

        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\d{1,15}$', ErrorMessage = 'This must be a 15 digit number.' )]
        [string]
        $ExtRangeSpan,

        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\d{1,15}$', ErrorMessage = 'This must be a 15 digit number.' )]
        [string]
        $ExtRangeSpanStart,

        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\d{1,15}$', ErrorMessage = 'This must be a 15 digit number.' )]
        [string]
        $ExtRangeSpanEnd,

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
        # Query the database for the range table
        $sqlQuery = @'
        INSERT INTO ExtRange (Department, Span, SpanStart, SpanEnd, Description) VALUES ('{0}', '{1}', '{2}', '{3}', '{4}');
'@ -f $DepartmentId, $ExtRangeSpan, $ExtRangeSpanStart, $ExtRangeSpanEnd, $ExtRangeDescription

        Write-Verbose "Adding row to the database in the range table. Query: $sqlQuery"
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row to database table 'ExtRange' with values Department '$DepartmentId', Span '$ExtRangeSpan', SpanStart '$ExtRangeSpanStart', SpanEnd '$ExtRangeSpanEnd' and Description '$ExtRangeDescription'", "Add")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # If the PassThru switch is set, query the database for the updated range and return it
        if ($PassThru) {
            $result = Get-TPNMExtRange -DepartmentId $DepartmentId -ExtRangeSpan $ExtRangeSpan -ExtRangeSpanStart $ExtRangeSpanStart -ExtRangeSpanEnd $ExtRangeSpanEnd
            
            # If needed, skip and limit the resultset
            # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
            Push-TPNMResultSet -ResultSet $result
        }
    }
}