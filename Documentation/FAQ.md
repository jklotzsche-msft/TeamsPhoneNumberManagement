# Frequently Asked Questions

## I get a "Connection Timeout Expired. The timeout period elapsed during the post-login phase." error when running the `Connect-TPNMDatabase` function. How can I fix this?

This error occurs when the connection to the database takes longer than the default timeout of 30 seconds. To fix this, you can increase the timeout by specifying the `SqlConnectionTimeout` parameter when calling the `Connect-TPNMDatabase` function. For example:

```powershell
Connect-TPNMDatabase -SqlConnectionTimeout 60
```

This will set the timeout to 60 seconds, allowing the connection to complete successfully.
You can do the same with the Function App code and Automation Account runbooks.

Alternatively, if you identified the database itself as the root cause of the issue, you can increase or disable the `auto-pause delay` in the Azure SQL Database settings. This will prevent the database from pausing and causing connection timeouts.

To learn more about the `auto-pause delay` setting, refer to the [Azure SQL Database documentation](https://learn.microsoft.com/en-us/azure/azure-sql/database/serverless-tier-overview?view=azuresql&tabs=general-purpose).

## I can see a new version of the TPNM module is available on PowerShell Gallery. How can I update the module?

If a new version of the TPNM module is available on PowerShell Gallery, you should update the module to benefit from the latest features and bug fixes. This includes the Function App, Automation Account and any other devices using the TPNM module.

To update a Function App, follow these steps:

1. Download Storage Explorer: Start by downloading and installing Storage Explorer, which will be used to manage the Function App.
2. Remove the existing module: In Storage Explorer, locate and delete the "TeamsPhoneNumberManagement" folder under "ManagedDependencies". This will remove the current version of the TPNM module.
3. Restart the Function App: Stop the Function App, wait a few seconds, and then start it again. This will trigger the reloading of the ManagedDependencies.
4. Trigger module reload: Make any endpoint call to the Function App to initiate the reloading of the ManagedDependencies. This will ensure that the updated version of the TPNM module is loaded.

To update an Automation Account, follow these steps:

1. Open the Automation Account: Start by opening the Automation Account in the Azure portal.
2. Delete the existing module: Locate and delete the "TeamsPhoneNumberManagement" module from the Modules section. This will remove the current version of the TPNM module.
3. Add the new module: Click on the "Add a module" button and search for the "TeamsPhoneNumberManagement" module. Select the latest version and add it to the Automation Account.

To update the TPNM module on other devices, follow these steps:

1. Open a PowerShell session: Start by opening a PowerShell session on the device where the TPNM module is installed.
2. Update the module: Run the following command to update the TPNM module to the latest version:

```powershell
Update-Module -Name TeamsPhoneNumberManagement
```
