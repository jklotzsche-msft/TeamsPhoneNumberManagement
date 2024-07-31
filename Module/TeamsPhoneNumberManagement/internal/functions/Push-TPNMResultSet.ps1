function Push-TPNMResultSet {
    <#
        .SYNOPSIS
        Processes and returns a subset of a result set with optional pagination.

        .DESCRIPTION
        The Push-TPNMResultSet function processes a provided result set and returns a subset of the results based on the specified ResultSize and Skip parameters. It supports pagination by allowing the caller to specify the number of results to return and the number of results to skip.

        .PARAMETER ResultSet
        The result set to be processed. This must be a list of PowerShell custom objects.

        .PARAMETER ResultSize
        The number of results to return. This can be a positive integer or the string 'unlimited' to return all results. Default is 100.

        .PARAMETER Skip
        The number of results to skip. This must be zero or a positive integer. Default is 0.

        .EXAMPLE
        $resultSet = Get-TPNMData
        $processedResults = Push-TPNMResultSet -ResultSet $resultSet -ResultSize 50 -Skip 10

        This example processes the result set by skipping the first 10 results and returning the next 50 results.

        .NOTES
        - This function sets the error action preference to 'Stop' to ensure that any errors encountered will stop the function execution.
        - The function validates the ResultSize and Skip parameters to ensure they are within acceptable ranges.
        - The function supports returning the full result set if ResultSize is set to 'unlimited'.
        - The function provides verbose output to indicate the processing steps.
        - If there are more results available than the specified ResultSize, a warning is issued.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    [OutputType([HashTable])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Generic.List[pscustomobject]]
        $ResultSet,

        [ValidateScript({
                if ($_ -is [int] -and $_ -ge 1) { $true }
                elseif ($_ -eq "unlimited") { $true }
                else { throw "ResultSize must be a positive integer value or the string 'unlimited'." }
            })]
        [Object]
        $ResultSize = 100,

        [ValidateScript({
                if ($_ -is [int] -and $_ -ge 0) { $true }
                else { throw "Skip must be zero or a positive integer value." }
            })]
        [int]
        $Skip = 0
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
        <# Removing the trap block to see real results (Success, Failure, etc.) in Azure Function App logs
        trap {
            Write-Error $_.Exception.Message
            return
        }
        #>
    }

    Process {
        # If there are more rows in the database, print a warning
        if ($ResultSize -eq "unlimited") {
            # return the full resultset
            Write-Verbose "Returning the full resultset."
            $ResultSet
            return
        }
        
        # Limit the resultset to the ResultSize and Skip the first rows, if needed
        Write-Verbose "Limiting the resultset to $ResultSize rows and skipping the first $Skip rows."
        $moreResults = $false
        $ResultSet = $ResultSet | Select-Object -Skip $Skip
        if ($ResultSet.Count -gt $ResultSize) {
            Write-Warning "There are more results available. Use the -ResultSize (and optionally -Skip) parameter to retrieve more results."
            $moreResults = $true
        }
        $ResultSet = $ResultSet | Select-Object -First $ResultSize

        # If the function is running in a function app, add a nextLink to the response
        # This will allow the caller to retrieve more results if needed
        if ($script:isFunctionApp) {
            $nextLink = "" # Initialize the nextLink to an empty string. Only needed if the function is running in a function app
            if ($moreResults) {
                $nextLink = "$($script:requestUri)?ResultSize=$ResultSize&Skip=$($Skip + $ResultSize)" # Only needed if the function is running in a function app
            }

            # prepare the resultset and the nextLink
            $resultObject = @{
                result   = $ResultSet
                nextLink = $nextlink
            }

            # return the $resultObject
            $resultObject
            return
        }

        # return the resultset
        $ResultSet
    }
}