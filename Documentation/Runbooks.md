# TeamsPhoneNumberManagement runbooks documentation

## Overview

The Automation Account is a cloud-based automation and configuration service that provides consistent management across your Azure and non-Azure environments. It consists of process automation, update management, and configuration features.

We will use the Automation Account to run the PowerShell scripts that will manage the phone numbers for Microsoft Teams.

There are two scripts (also known as runbooks) that will be used to manage the phone numbers:

1. **Enable-TeamsPhone**: This script enables Teams Telephony for users in the onboarding group by performing the following actions:
    - Connects to Microsoft Graph and Microsoft Teams using managed identity.
    - Retrieves all users in the onboarding group.
    - Validates user details, such as phone number, license, and Teams settings.
    - Activates users for Teams calling and assigns Voice Routing Policy and Dial Plan.
    - Disconnects from Microsoft Teams and Microsoft Graph.

2. **Update-TPNMDatabase**: This script connects to Azure, Teams, and the TPNM database using the Managed Identity of the Azure Automation Account.
    It then performs the following tasks:
    1. Checks if the requested allocations have been used in Teams.
        - If a number has been assigned to a Teams EV user, it updates the state column of the specific row in the allocation table to 'Assigned'.
        - If a number has been assigned to multiple users, it displays a warning message.
        - If a number has not been assigned to any user, it removes the specific row from the allocation table.
    2. Checks if the assigned allocations have been removed from Teams.
        - If a number has been removed from a Teams EV user or the user has been deleted, it removes the specific row from the allocation table.
        - If a number has been assigned to multiple users, it displays a warning message.
    3. Checks if all used PSTN numbers in Teams are listed in the TPNM allocation table.
        - If a number is not listed, it adds the specific row to the allocation table with the state 'Assigned'.

## Deployment

Please refer to the [Deployment Guide](./Deployment.md) for detailed instructions on deploying the Automation Account. The deployment guide also includes the steps to create and configure the automation account, import the runbooks, and configure the required variables.

If you have the TeamsPhoneNumbersManagement solution deployed and want to update the runbooks, you can use the [Set-AzureRunbook.ps1 script](../AutomationAccount/build/Set-AzureRunbook.ps1) to update the runbooks in the Automation Account. Please check the help of the script for more information using the following command:

```powershell
Get-Help -Name .\Set-AzureRunbook.ps1 -Full
```
