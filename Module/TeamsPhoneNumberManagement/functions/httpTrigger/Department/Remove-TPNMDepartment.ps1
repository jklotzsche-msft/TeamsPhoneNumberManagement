function Remove-TPNMDepartment {
    <#
        .SYNOPSIS
        Removes a department from the database.

        .DESCRIPTION
        The Remove-TPNMDepartment function removes an existing department from the database table 'Department'.
        A department is a record that is used to group extensions together.

        .PARAMETER DepartmentId
        The ID of the department to remove.
        It should be a string with a maximum of 5 digits.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Remove-TPNMDepartment -DepartmentId "12345"

        This example removes the department with the specified DepartmentId from the database.

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
        $DepartmentId
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        # Query the database for the department table
        $sqlQuery = @'
DELETE FROM Department
WHERE ID = {0};
'@ -f $DepartmentId

        Write-Verbose "Removing row $DepartmentId from database table department."
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row with ID $DepartmentId from database table 'Department'", "Remove")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }
    }
}