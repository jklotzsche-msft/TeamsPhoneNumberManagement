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