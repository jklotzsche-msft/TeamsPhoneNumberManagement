# TeamsPhoneNumberManagement Api documentation

## Overview

The Azure Function App provides an API to manage the TPNM database. The API is secured using Azure AD authentication and can be accessed using any tool that can send HTTP requests. The core of the Azure Function App is the custom PowerShell module that is used to manage the TPNM database. The very same functions that are available in the PowerShell module are also available in the Azure Function App as HTTP endpoints.

You can use this API to manage the phone numbers for your Teams users in a structured and automated way, as well as request phone numbers for your Teams users from any tool that can send HTTP requests.

## Authentication

The API is secured using Azure AD authentication. You need to authenticate using a user account that has the necessary permissions to manage the TPNM database. The user account must be a member of the Azure AD group that is assigned to the Azure Function App. The Azure Function App is configured to only allow members of the assigned Azure AD group to access the API.

Alternatively, you can use an client secret or certificate to authenticate with the API. This is useful if you want to use the API in an automated way, for example from a script or a tool that can send HTTP requests.

## API Endpoints

This solution uses different HTTP methods for each type of operation. The following table shows the mapping between the HTTP methods and the operations that can be performed:

| HTTP Method | Operation | PowerShell Function |
|-------------|-----------|---------------------|
| GET         | Read      | Get-\<Resource>     |
| POST        | Create    | Add-\<Resource>     |
| POST        | Request   | Request-\<Resource> |
| PATCH       | Update    | Set-\<Resource>     |
| DELETE      | Delete    | Remove-\<Resource>  |

The following endpoints are available in the API:

### Country

These endpoints are used to manage the countries that are available in the TPNM database.

- [GetCountry](./GetCountry.md) to list all countries or filter by country ID, country code, or country name.
- [SetCountry](./SetCountry.md) to update the details of a single country.
- [AddCountry](./AddCountry.md) to add a single country.
- [RemoveCountry](./RemoveCountry.md) to remove a single country.

### Forbidden

These endpoints are used to manage the forbidden extensions that are available in the TPNM database.

- [GetForbidden](./GetForbidden.md) to list all forbidden extensions or filter by forbidden extension ID, fordbidden extension number, or country information as country ID, country code, or country name.
- [SetForbidden](./SetForbidden.md) to update the details of a single forbidden extension.
- [AddForbidden](./AddForbidden.md) to add a single forbidden extension.
- [RemoveForbidden](./RemoveForbidden.md) to remove a single forbidden extension.

### Department

These endpoints are used to manage the departments that are available in the TPNM database.

- [GetDepartment](./GetDepartment.md) to list all departments or filter by department ID, department name, or country information as country ID, country code, or country name.
- [SetDepartment](./SetDepartment.md) to update the details of a single department.
- [AddDepartment](./AddDepartment.md) to add a single department.
- [RemoveDepartment](./RemoveDepartment.md) to remove a single department.

### ExtRange

These endpoints are used to manage the extension ranges that are available in the TPNM database.

- [GetExtRange](./GetExtRange.md) to list all extension ranges or filter by extension range ID, extension range span, extension range span start, extension range span end, or department information as department ID, department name, or country information as country ID, country code, or country name.
- [SetExtRange](./SetExtRange.md) to update the details of a single extension range.
- [AddExtRange](./AddExtRange.md) to add a single extension range.
- [RemoveExtRange](./RemoveExtRange.md) to remove a single extension range.

### Allocation

These endpoints are used to manage the allocations that are available in the TPNM database.

- [GetAllocation](./GetAllocation.md) to list all allocations or filter by allocation ID, allocation number, allocation state, or extension range information as extension range ID, extension range span, or department information as department ID, department name, or country information as country ID, country code, or country name.
- [SetAllocation](./SetAllocation.md) to update the details of a single allocation.
- [AddAllocation](./AddAllocation.md) to add a single allocation.
- [RemoveAllocation](./RemoveAllocation.md) to remove a single allocation.
- [RequestAllocation](./RequestAllocation.md) to request a new allocation. This function is the main function to request a new phone number for a user from any tool that can send HTTP requests.

### ExtensionInUse

These endpoints are used to manage the extensions that are in use in the TPNM database.

- [GetExtensionInUse](./GetExtensionInUse.md) to list all extensions that are in use by allocation or blocked by forbidden numbers. You can filter by extension range id, extension range span, department id, department name, country id, country name, or country code. Additionally, you can filter by forbidden only.

## Example API Call

The following example shows how to use the API to request a new phone number for a user:

```powershell
$uri = "https://<function-app-name>.azurewebsites.net/api/RequestAllocation"
$headers = @{"Authorization" = "Bearer <access-token>"}
$body = @{
    "CountryCode" = "US"
}
Invoke-RestMethod -Uri $uri -Method Post -Body ($body | ConvertTo-Json) -ContentType "application/json"

# This will create a new allocation for a phone number in the US. The API will return the new allocation ID, the new phone number, and the extension range that the phone number belongs to.
```

## API Reference

For more information about the API endpoints, refer to the comment-based help of the functions in the custom PowerShell module. The comment-based help provides detailed information about the parameters and return values of the functions.
