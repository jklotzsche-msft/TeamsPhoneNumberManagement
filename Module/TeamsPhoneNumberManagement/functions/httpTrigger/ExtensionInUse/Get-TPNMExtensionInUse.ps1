function Get-TPNMExtensionInUse {
    <#
        .SYNOPSIS
        Retrieves all extensions in use from the database.

        .DESCRIPTION
        The Get-TPNMExtensionInUse function retrieves all extensions in use from the database.
        It joins the Allocation, ExtRange, Department, and Country tables to provide detailed information about each extension in use.
        It also retrieves all forbidden extensions from the database and adds them to the resultset.

        .PARAMETER CountryId
        The ID of the country.
        It should be a string with a maximum of 5 digits.

        .PARAMETER CountryName
        The name of the country.
        It should be a two-letter, uppercase string.

        .PARAMETER CountryCode
        The country code.
        It should be a plus character followed by a maximum of four digits.

        .PARAMETER DepartmentId
        The ID of the department.
        It should be a string with a maximum of 5 digits.

        .PARAMETER DepartmentName
        The name of the department.
        It should be a string with a maximum of 15 characters.

        .PARAMETER ExtRangeId
        The ID of the extension range.
        It should be a string with a maximum of 5 digits.

        .PARAMETER ExtRangeSpan
        The span of the extension range.
        It should be a string with a maximum of 15 characters.

        .PARAMETER ForbiddenOnly
        Switch parameter to only return forbidden extensions.

        .PARAMETER ResultSize
        The maximum number of results to return.
        It should be a positive integer or the string 'unlimited'. Default is 100.

        .PARAMETER Skip
        The number of results to skip.
        It should be zero or a positive integer. Default is 0.

        .EXAMPLE
        Get-TPNMExtensionInUse -CountryId "12345"

        This example retrieves all extensions in use for the specified country ID.

        .EXAMPLE
        Get-TPNMExtensionInUse -CountryName "US"

        This example retrieves all extensions in use for the specified country name.

        .EXAMPLE
        Get-TPNMExtensionInUse -CountryCode "+1"

        This example retrieves all extensions in use for the specified country code.

        .EXAMPLE
        Get-TPNMExtensionInUse -DepartmentId "12345"

        This example retrieves all extensions in use for the specified department ID.

        .EXAMPLE
        Get-TPNMExtensionInUse -DepartmentName "Sales"

        This example retrieves all extensions in use for the specified department name.

        .EXAMPLE
        Get-TPNMExtensionInUse -ExtRangeId "12345"

        This example retrieves all extensions in use for the specified extension range ID.

        .EXAMPLE
        Get-TPNMExtensionInUse -ForbiddenOnly

        This example retrieves all forbidden extensions.

        .NOTES
        - This function requires the Get-TPNMAllocation, Get-TPNMExtRange, and Get-TPNMForbidden functions to be available.
        - The error action preference is set to 'Stop' to stop the function on any error.
        - The function uses verbose output to provide detailed information about the SQL query execution.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $CountryId,

        [ValidatePattern( '^[A-Z]{2}$', ErrorMessage = 'The Country Name must be a two-letter, uppercase string' )]
        [string]
        $CountryName,

        [ValidatePattern( '^\+\d{1,4}$', ErrorMessage = 'The country code must be a plus character followed by maximum four digits.' )]
        [string]
        $CountryCode,

        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $DepartmentId,

        [ValidatePattern( '^\w{1,15}$', ErrorMessage = 'The department name must be at maximum a 15 character string.' )]
        [string]
        $DepartmentName,

        [ValidatePattern( '^\d{1,5}$', ErrorMessage = 'The id must be at maximum a 5 digit number.' )]
        [string]
        $ExtRangeId,

        [ValidatePattern( '^\d{1,15}$', ErrorMessage = 'This must be a 15 digit number.' )]
        [string]
        $ExtRangeSpan,

        [Switch]
        $ForbiddenOnly,

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
    }

    Process {
        # Prepare resultset
        $resultSet = [System.Collections.Generic.List[pscustomobject]]::new()

        # Get all allocations from the database and return them individually as pscustomobject
        if (-not $ForbiddenOnly) {
            # Prepare hashtable for splatting
            $getTPNMsplat = @{}

            # Add parameters to the splatting hashtable for Get-TPNMAllocation
            $commandInfo = Get-Command -Name 'Get-TPNMAllocation'
            foreach ($passedParameter in $PSBoundParameters.GetEnumerator()) {
                foreach ($parameter in $commandInfo.Parameters.Keys) {
                    if ($parameter -eq $passedParameter.Key) {
                        $getTPNMsplat[$parameter] = $passedParameter.Value
                    }
                }
            }

            Write-Verbose "Getting all allocations from the database."
            Get-TPNMAllocation @getTPNMsplat | ForEach-Object -Process {
                $resultSet.Add([PSCustomObject]$_)
            }
        }

        # Get all ranges from the database to identify forbidden extensions, so we can add them to the resultset
        Write-Verbose "Getting all ranges from the database."
        # Prepare hashtable for splatting
        $getTPNMRange = @{}

        # Add parameters to the splatting hashtable for Get-TPNMExtRange
        $commandInfo = Get-Command -Name 'Get-TPNMExtRange'
        foreach ($passedParameter in $PSBoundParameters.GetEnumerator()) {
            foreach ($parameter in $commandInfo.Parameters.Keys) {
                if ($parameter -eq $passedParameter.Key) {
                    $getTPNMRange[$parameter] = $passedParameter.Value
                }
            }
        }
        $sqlResultRange = Get-TPNMExtRange @getTPNMRange

        # Prepare hashtable for splatting
        $getTPNMForbiddensplat = @{}

        # Add parameters to the splatting hashtable for Get-TPNMForbidden
        $commandInfo = Get-Command -Name 'Get-TPNMForbidden'
        foreach ($passedParameter in $PSBoundParameters.GetEnumerator()) {
            foreach ($parameter in $commandInfo.Parameters.Keys) {
                if ($parameter -eq $passedParameter.Key) {
                    $getTPNMForbiddensplat[$parameter] = $passedParameter.Value
                }
            }
        }

        # Get all forbidden extensions from the database by using the country code from the range
        $sqlResultForbidden = [System.Collections.Generic.List[pscustomobject]]::new()
        foreach ($countryName in ($sqlResultRange.CountryName | Select-Object -Unique)) {
            $getTPNMForbiddensplat.'CountryName' = $countryName
            Write-Verbose "Getting all forbidden extensions from the database for country $countryName."
            Get-TPNMForbidden @getTPNMForbiddensplat | ForEach-Object -Process {
                $sqlResultForbidden.Add([PSCustomObject]$_)
            }
        }

        # Iterate over all ranges and forbidden extensions and return them individually as pscustomobject
        Write-Verbose "Iterating over all ranges and forbidden extensions."
        foreach ($forbidden in $sqlResultForbidden) {
            Write-Debug "Checking forbidden extension $($forbidden.ForbiddenId)."
            foreach ($range in $sqlResultRange) {
                Write-Debug "Comparing to range $($range.ExtRangeId)."

                # If the country code of the range and forbidden extension do not match, skip the entry
                if ($range.CountryCode -ne $forbidden.CountryCode) {
                    Write-Debug "Country code of the range ($($range.CountryCode)) and forbidden extension ($($forbidden.CountryCode)) do not match. Skipping entry."
                    continue
                }

                # If the forbidden extension is not in the range, skip the entry
                if ([int]$forbidden.ForbiddenExtension -lt [int]$range.ExtRangeSpanStart -or [int]$forbidden.ForbiddenExtension -gt [int]$range.ExtRangeSpanEnd) {
                    Write-Debug "Forbidden extension $($forbidden.ForbiddenExtension) is not in the range $($range.ExtRangeSpan) with span $($range.ExtRangeSpanStart) - $($range.ExtRangeSpanEnd). Skipping entry."
                    continue
                }

                # Create a new entry for each forbidden extension in the range
                Write-Debug "Creating a new result object for forbidden extension $($forbidden.ForbiddenId) in range $($range.ExtRangeId)."
                $newEntry = [ordered]@{
                    AllocationId          = $forbidden.ForbiddenId
                    AllocationExtension   = $forbidden.ForbiddenExtension
                    AllocationState       = 'Forbidden'
                    AllocationCreatedOn   = ''
                    AllocationDescription = $forbidden.ForbiddenDescription
                    ExtRangeId            = $range.ExtRangeId
                    ExtRangeSpan          = $range.ExtRangeSpan
                    ExtRangeSpanStart     = $range.ExtRangeSpanStart
                    ExtRangeSpanEnd       = $range.ExtRangeSpanEnd
                    DepartmentId          = $range.DepartmentId
                    DepartmentName        = $range.DepartmentName
                    CountryId             = $forbidden.CountryId
                    CountryCode           = $forbidden.CountryCode
                    CountryName           = $forbidden.CountryName
                }

                # Return all results individually as pscustomobject
                $resultSet.Add([pscustomobject]$newEntry)

                # Continue with the next forbidden extension by breaking this inner loop
                break
            }
        }
        Write-Verbose "Returned all results individually as pscustomobject. Found $($resultSet.Count) entries."

        # If no extension in use is found, stop the function and return a warning
        if ($resultSet.Count -eq 0) {
            Write-Warning -Message 'No extension in use found.'
            return
        }

        # If needed, skip and limit the resultset
        # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
        Push-TPNMResultSet -ResultSet $resultSet -ResultSize $ResultSize -Skip $Skip
    }
}