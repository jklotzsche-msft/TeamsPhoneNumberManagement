function Add-TPNMDepartment {
    <#
        .SYNOPSIS
        Adds a new department to the database.

        .DESCRIPTION
        The Add-TPNMDepartment function adds a new department to the database table 'Department'.
        A department record includes the country id, department name, and an optional description.

        .PARAMETER CountryId
        The ID of the country.
        It should be a string with a maximum of 5 digits.

        .PARAMETER DepartmentName
        The name of the department.
        It should be a string with a maximum of 15 characters.

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
        Add-TPNMDepartment -CountryId "123" -DepartmentName "Sales"

        This example adds a new department to the database with the specified parameters.

        .NOTES
        - This function requires the Invoke-TPNMSqlRequest and Get-TPNMDepartment functions to be available.
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
        $CountryId,

        [Parameter(Mandatory = $true)]
        [ValidatePattern( '^\w{1,15}$', ErrorMessage = 'The department name must be at maximum a 15 character string.' )]
        [string]
        $DepartmentName,

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
        # Query the database for the department table
        $sqlQuery = @'
        INSERT INTO Department (Country, Name, Description) VALUES ('{0}', '{1}', '{2}');
'@ -f $CountryId, $DepartmentName, $DepartmentDescription

        Write-Verbose "Adding row to the database in the department table. Query: $sqlQuery"
        # Execute the query with confirmation by default
        if ($PSCmdlet.ShouldProcess("Row to database table 'Department' with values Country '$CountryId', Name '$DepartmentName' and Description '$DepartmentDescription'", "Add")) {
            $null = Invoke-TPNMSqlRequest -SqlQuery $sqlQuery
        }

        # If the PassThru switch is set, query the database for the updated department and return it
        if ($PassThru) {
            $result = Get-TPNMDepartment -CountryId $CountryId -DepartmentName $DepartmentName
            
            # If needed, skip and limit the resultset
            # Then return the resultset, or if the function is used in an Azure Function App, push the resultset including the nextLink
            Push-TPNMResultSet -ResultSet $result
        }
    }
}