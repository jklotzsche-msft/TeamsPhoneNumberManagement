function ConvertFrom-TPNMSqlResult {
	<#
		.SYNOPSIS
		Converts SQL result objects to PowerShell custom objects.

		.DESCRIPTION
		The ConvertFrom-TPNMSqlResult function takes SQL result objects (DataRow, DataTable, or DataSet) and converts them into PowerShell custom objects for easier manipulation and readability.

		.PARAMETER InputObject
		The SQL result object to be converted. It can be a DataRow, DataTable, or DataSet.

		.EXAMPLE
		$dataRow = Get-SomeDataRow
		$customObject = $dataRow | ConvertFrom-TPNMSqlResult

		This example converts a DataRow object into a PowerShell custom object.

		.EXAMPLE
		$dataTable = Get-SomeDataTable
		$customObjects = $dataTable | ConvertFrom-TPNMSqlResult

		This example converts a DataTable object into an array of PowerShell custom objects.

		.EXAMPLE
		$dataSet = Get-SomeDataSet
		$customObjects = $dataSet | ConvertFrom-TPNMSqlResult

		This example converts a DataSet object into an array of PowerShell custom objects.

		.NOTES
		- This function sets the error action preference to 'Stop' to ensure that any errors encountered will stop the function execution.
		- The function includes a nested helper function, ConvertFrom-DataRow, which handles the conversion of individual DataRow objects.
		- The function filters out default properties that are not needed in the custom object.

		.LINK
		https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement
	#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject
	)

	begin {
		# Set the error action preference to stop
		$ErrorActionPreference = 'Stop'
		function ConvertFrom-DataRow {
			[CmdletBinding()]
			param (
				[System.Data.DataRow]
				$Row,

				[string[]]
				$Properties
			)

			if (-not $Properties) {
				$defaultProperties = 'CustomMemberOptions', 'RowError', 'RowState', 'Table', 'ItemArray', 'HasErrors'
				$Properties = $Row.PSObject.Properties.Name | Where-Object { $_ -notin $defaultProperties }
			}
			$hash = @{ }
			foreach ($propertyName in $Properties) {
				$hash.$propertyName = $Row.$propertyName
			}
			[pscustomobject]$hash
		}
	}
	process {
		foreach ($item in $InputObject) {
			if ($item -is [System.Data.DataRow]) {
				ConvertFrom-DataRow -Row $item
			}
			if ($item -is [System.Data.DataTable]) {
				foreach ($row in $Item) {
					ConvertFrom-DataRow -Row $row -Properties $Item.Columns.ColumnName
				}
			}
			if ($item -is [System.Data.DataSet]) {
				foreach ($table in $item.Tables) {
					foreach ($row in $table) {
						ConvertFrom-DataRow -Row $row -Properties $table.Columns.ColumnName
					}
				}
			}
		}
	}
}