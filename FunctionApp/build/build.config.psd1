@{
	TimerTrigger = @{
		# Default Schedule for timed executions
		Schedule          = '0 5 * * * *'

		# Different Schedules for specific timed endpoints
		ScheduleOverrides = @{
			# 'Update-Whatever' = '0 5 12 * * *'
		}
	}

	HttpTrigger  = @{
		<#
		AuthLevels:
		https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-http-webhook-trigger?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cfunctionsv2&pivots=programming-language-csharp#http-auth

		anonymous: No Token needed (combine with Identity Provider for Entra ID auth without also needing a token)
		function: (default) Require a function-endpoint-specific token with the request
		admin: Require a Function-App-global admin token (master key) for the request
		#>
		AuthLevel          = 'anonymous'
		AuthLevelOverrides = @{
			# 'Set-Foo' = 'anonymous'
		}

		<#
		Methods:
		https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-http-webhook-trigger?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cfunctionsv2&pivots=programming-language-csharp#http-methods
		
		get: HTTP GET request for reading data
		post: HTTP POST request for creating data
		put: HTTP PATCH request for updating data
		delete: HTTP DELETE request for deleting data
		#>
		Method             = 'get'
		MethodOverrides    = @{
			'Add-TPNMAllocation'     = 'post'
			'Add-TPNMCountry'        = 'post'
			'Add-TPNMDepartment'     = 'post'
			'Add-TPNMExtRange'       = 'post'
			'Add-TPNMForbidden'      = 'post'

			'Request-TPNMAllocation' = 'post'

			'Remove-TPNMAllocation'  = 'delete'
			'Remove-TPNMCountry'     = 'delete'
			'Remove-TPNMDepartment'  = 'delete'
			'Remove-TPNMExtRange'    = 'delete'
			'Remove-TPNMForbidden'   = 'delete'

			'Set-TPNMAllocation'     = 'patch'
			'Set-TPNMCountry'        = 'patch'
			'Set-TPNMDepartment'     = 'patch'
			'Set-TPNMExtRange'       = 'patch'
			'Set-TPNMForbidden'      = 'patch'
		}		
	}
}