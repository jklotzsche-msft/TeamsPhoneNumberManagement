function Get-TPNMNextFreeNumberByExtRange {
    <#
        .SYNOPSIS
        Finds the next free extension number within a specified range.

        .DESCRIPTION
        The Get-TPNMNextFreeNumberByExtRange function searches for the next available extension number within a given range that is not currently in use. It supports ranges with leading zeros if enabled.

        .PARAMETER ExtRange
        A PSCustomObject representing the extension range. It should contain ExtRangeSpanStart and ExtRangeSpanEnd properties.

        .PARAMETER ExtensionsInUse
        An array of PSCustomObject representing the extensions that are currently in use. It should contain AllocationExtension properties.

        .PARAMETER EnableLeadingZero
        A switch parameter to enable support for leading zeros in the extension range.

        .EXAMPLE
        $extRange = [PSCustomObject]@{ ExtRangeSpanStart = "1000"; ExtRangeSpanEnd = "2000"; ExtRangeId = 1 }
        $extensionsInUse = @([PSCustomObject]@{ AllocationExtension = "1001" }, [PSCustomObject]@{ AllocationExtension = "1002" })
        Get-TPNMNextFreeNumberByExtRange -ExtRange $extRange -ExtensionsInUse $extensionsInUse

        This example finds the next free extension number within the range 1000 to 2000, excluding 1001 and 1002.

        .EXAMPLE
        $extRange = [PSCustomObject]@{ ExtRangeSpanStart = "0100"; ExtRangeSpanEnd = "0200"; ExtRangeId = 1 }
        $extensionsInUse = @([PSCustomObject]@{ AllocationExtension = "0101" }, [PSCustomObject]@{ AllocationExtension = "0102" })
        Get-TPNMNextFreeNumberByExtRange -ExtRange $extRange -ExtensionsInUse $extensionsInUse -EnableLeadingZero

        This example finds the next free extension number within the range 0100 to 0200, excluding 0101 and 0102, with leading zero support enabled.

        .NOTES
        - This function sets the error action preference to 'Stop' to ensure that any errors encountered will stop the function execution.
        - The function checks for leading zeros in the range if the EnableLeadingZero switch is used.
        - The function iterates through the range and returns the first available extension number that is not in use.

        .LINK
        https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]
        $ExtRange,

        [Parameter(Mandatory = $true)]
        [PSCustomObject[]]
        $ExtensionsInUse,

        [Parameter(DontShow = $true)]
        [switch]
        $EnableLeadingZero
    )

    # Add support for leading zeros in the range, if enabled
    if ($EnableLeadingZero -eq $true) {
        $leadingZeroFound = [bool]($ExtRange.ExtRangeSpanStart.Length - $ExtRange.ExtRangeSpanStart.TrimStart('0').Length)
        $ExtRangeSpanEndDigitCount = $ExtRange.ExtRangeSpanEnd.Length
    }

    Write-Verbose "Finding next free number in range $($ExtRange.ExtRangeSpanStart)..$($ExtRange.ExtRangeSpanEnd)"
    foreach ($extension in $($ExtRange.ExtRangeSpanStart)..$($ExtRange.ExtRangeSpanEnd)) {
        if (($EnableLeadingZero -eq $true) -and ($leadingZeroFound -eq $true)) {
            # If the extension is shorter than the range start, add leading zeros
            $extension = ("0" * ($ExtRangeSpanEndDigitCount - ([string]$extension).Length)) + [string]$extension
        }

        # If the extension is not in use, reserve it in the database
        if ($ExtensionsInUse.AllocationExtension -notcontains $extension) {
            $nextFreeNumber = [PSCustomObject]@{
                ExtRangeId = $ExtRange.ExtRangeId
                Extension  = $extension
            }
            $nextFreeNumber
            break
        }
    }
    Write-Verbose "Found next free number: $($nextFreeNumber.NumberShort)"
}