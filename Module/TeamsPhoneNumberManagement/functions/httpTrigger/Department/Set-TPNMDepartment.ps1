function Set-TPNMDepartment {
    <#
        .SYNOPSIS
        Updates a department in the database.

        .DESCRIPTION
        The Set-TPNMDepartment function updates an existing department in the database table 'Department'.
        A department is a record that is used to group extensions together.
        The function can update the department description.

        .PARAMETER DepartmentId
        The ID of the department to update.
        It should be a string with a maximum of 5 digits.

        .PARAMETER DepartmentDescription
        The description of the department.
        It should be a string with a maximum of 100 characters (including whitespace).

        .PARAMETER PassThru
        Switch parameter to return the updated department.
        
        .PARAMETER Confirm
        Switch parameter to confirm the execution of the function.

        .PARAMETER WhatIf
        Switch parameter to simulate the execution of the function.

        .EXAMPLE
        Set-TPNMDepartment -DepartmentId "12345" -DepartmentDescription "The new description"

        This example updates the department with the specified DepartmentId with the new description.

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Get-TPNMDepartment functions to be available.
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
        $DepartmentId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Description')]
        [ValidatePattern( '^[a-zA-Z0-9\s-_]{1,100}$', ErrorMessage = 'The description must be at maximum a 100 character string. It can contain letters, numbers, whitespace, and the characters "-" and "_"' )]
        [string]
        $DepartmentDescription,

        [switch]
        $PassThru
    )
    
    Begin {
        # Set the error action preference to stop and trap the error.
        $ErrorActionPreference = 'Stop'
    }

    Process {
        if ($DepartmentDescription) {
            $Column = 'Description'
            $Value = $DepartmentDescription
        }

        # Query the database for the department table
        $sqlQuery = @'
        UPDATE Department SET {0}='{1}'
        WHERE ID='{2}';
'@ -f $Column, $Value, $DepartmentId

        Write-Verbose "Updating the database for the department table. Query: $sqlQuery"
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row with ID $DepartmentId from database table 'Department', setting $Column to '$Value'", "Set")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # If the PassThru switch is set, query the database for the updated department and return it
        if ($PassThru) {
            $result = Get-TPNMDepartment -DepartmentId $DepartmentId
            
            # If needed, skip and limit the resultset
            # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
            Push-TPNMResultSet -ResultSet $result
        }
    }
}