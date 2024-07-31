<#
    .SYNOPSIS
    Enable Teams Telephony for users in the onboarding group.

    .DESCRIPTION
    This script enables Teams Telephony for users in the onboarding group by performing the following actions:
    - Connects to Microsoft Graph and Microsoft Teams using managed identity.
    - Retrieves all users in the onboarding group.
    - Validates user details, such as phone number, license, and Teams settings.
    - Activates users for Teams calling and assigns Voice Routing Policy and Dial Plan.
    - Disconnects from Microsoft Teams and Microsoft Graph.

    .PARAMETER TPNMAuto_OnboardingSecurityGroupId
    The security group ID for onboarding.
    Default value is retrieved from the 'TPNMAuto_OnboardingSecurityGroupId' automation variable.

    .PARAMETER TPNM_PhoneNumberType
    The type of phone number.
    Default value is retrieved from the 'TPNM_PhoneNumberType' automation variable. Should be "DirectRouting".

    .PARAMETER TPNMAuto_TeamsVoiceRoutingPolicy
    The name of the Microsoft Teams Online Voice Routing Policy.
    Default value is retrieved from the 'TPNMAuto_TeamsVoiceRoutingPolicy' automation variable.

    .PARAMETER TPNMAuto_TeamsDialPlanPolicy
    The name of the Microsoft Teams Dial Plan.
    Default value is retrieved from the 'TPNMAuto_TeamsDialPlanPolicy' automation variable.

    .EXAMPLE
    .\Enable-TeamsPhone.ps1

    This example enables Teams Telephony for users in the onboarding group using the default parameter values.
    The default parameter values are obtained from the automation variables of the Azure Automation account.
    Please check the TPNM deployment guide for more information on how to set up these automation variables.

    .EXAMPLE
    .\Enable-TeamsPhone.ps1 -TPNMAuto_OnboardingSecurityGroupId '12345678-1234-1234-1234-1234567890AB' -TPNM_PhoneNumberType 'DirectRouting' -TPNMAuto_TeamsVoiceRoutingPolicy 'VoiceRoutingPolicy' -TPNMAuto_TeamsDialPlanPolicy 'DialPlan'

    This example enables Teams Telephony for users in the onboarding group with custom parameter values.
#>

[CmdletBinding()]
param(
    [guid]
    $TPNMAuto_OnboardingSecurityGroupId = (Get-AutomationVariable -Name 'TPNMAuto_OnboardingSecurityGroupId'),

    [string]
    $TPNM_PhoneNumberType = (Get-AutomationVariable -Name 'TPNM_PhoneNumberType'),

    [string]
    $TPNMAuto_TeamsVoiceRoutingPolicy = (Get-AutomationVariable -Name 'TPNMAuto_TeamsVoiceRoutingPolicy'),

    [string]
    $TPNMAuto_TeamsDialPlanPolicy = (Get-AutomationVariable -Name 'TPNMAuto_TeamsDialPlanPolicy')
)

#region Additional Helper Functions

function Write-DebugToOutputStream {
    <#
    .SYNOPSIS
    Write a debug message to the output stream of the Azure Automation job.
    
    .DESCRIPTION
    Azure Automation does not have a debug stream for the job output.
    Therefore, we have to use the output stream of the job to write debug messages.
    This function will write a debug message to the output stream of the Azure Automation job.
    
    .PARAMETER Message
    String value of the debug message
    
    .EXAMPLE
    Write-DebugToOutputStream -Message 'This is my debug message'

    This example will write the debug message 'This is my debug message' to the output stream of the Azure Automation job.

    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $Message
    )
	
    Write-Debug -Message $Message 5>&1
}

#endregion

#region Connect to Graph and Teams

# Enable debug logging to debug stream of Azure Automation
# All debug messages will be written to the output stream of the Azure Automation job
# This is needed, because Azure Automation does not have a debug stream for the job output
$global:DebugPreference = "Continue"

# Connect to Microsoft Graph using managed identity
Write-DebugToOutputStream -Message 'Connecting to Microsoft Graph...'
Connect-MgGraph -Identity
Write-DebugToOutputStream -Message '...OK'

# Connect to MS Teams using managed identity
Write-DebugToOutputStream -Message 'Connecting to Teams...'
Connect-MicrosoftTeams -Identity
Write-DebugToOutputStream -Message '...OK'

#endregion

#region EnableTeamsTelephony

# Get all users in scope for Teams telephony
$properties = @(
    'Id',
    'UserPrincipalName',
    'BusinessPhones'
)
Write-DebugToOutputStream -Message 'Getting all users in the onboarding group...'
$onboardingGroupMembers = Get-MgGroupMember -GroupId $teamsTelephonyConfig.OnboardingSecurityGroupId -All:$true
Write-DebugToOutputStream -Message '...OK'

# Iterate all users in the onboarding group and check if they really exist in the directory
foreach ($onboardingUser in $onboardingGroupMembers) {
    # Get user details
    try {
        $user = Get-MgUser -UserId $onboardingUser.Id -Property $properties -ErrorAction Stop
    }
    catch {
        Write-Warning "User '$($onboardingUser.Id)' is not found in the directory"
        continue
    }

    # Check if the user has a phone number assigned
    if ([string]::IsNullOrEmpty($user.BusinessPhones)) {
        Write-Warning "User '$($user.UserPrincipalName)' does not have a phone number assigned"
        continue
    }

    # Validate, that the business phone number contains valid characters only
    if ($user.BusinessPhones -notmatch '^\+?[0-9]+$') {
        Write-Warning "User '$($user.UserPrincipalName)' has an invalid phone number: $($user.BusinessPhones)"
        continue
    }

    # Validate, that the user has a valid teams license assigned
    # The ServicePlanname 'TEAMS1' is the same for all tenants and represents the Teams license
    $userLicenses = Get-MgUserLicenseDetail -UserId $user.id
    if ($null -eq ($userLicenses | Where-Object -FilterScript { $_.ServicePlans.ServicePlanname -eq 'TEAMS1' })) {
        Write-Warning "User '$($user.UserPrincipalName)' does not have a Teams license assigned"
        continue
    }

    # Validate, that the user has a valid phone system license assigned
    # This Id e43b5b99-8dfb-405f-9987-dc307f34bcbd is the Phone System license ID and the same for all tenants
    if ($null -eq ($userLicenses | Where-Object -FilterScript { $_.SkuId -eq "e43b5b99-8dfb-405f-9987-dc307f34bcbd" })) {
        Write-Warning "User '$($user.UserPrincipalName)' does not have a Phone System license assigned"
        continue
    }

    # Get Teams settings of user
    try {
        $teamsUser = Get-CsOnlineUser -Identity $user.UserPrincipalName -ErrorAction Stop | Select-Object -Property EnterpriseVoiceEnabled, OnPremLineURI, LineURI, OnlineVoiceRoutingPolicy, TenantDialPlan
    }
    catch {
        Write-Warning "User '$($user.UserPrincipalName)' is not found in Teams"
        continue
    }

    # Remember the actions that are required for this user
    $enableEnterpriseVoice = $false
    $updateOnPremLineUri = $false

    # Check for Enterprise Voice feature
    if (-not $teamsUser.EnterpriseVoiceEnabled) {
        $enableEnterpriseVoice = $true
    }

    # Check if the telephone number is correct
    if (("tel:$($user.BusinessPhones)" -ne $teamsUser.OnPremLineURI) -and ("tel:$($user.BusinessPhones)" -ne $teamsUser.LineURI)) {
        $updateOnPremLineUri = $true
    }

    if ($enableEnterpriseVoice -or $updateOnPremLineUri) {
        Write-DebugToOutputStream -Message "Setting up user '$($user.UserPrincipalName)' for Teams calling..."
        # Activate user for Teams calling (including Enterprise Voice, Hosted Voice Mail and update of Telephone Number)
        try {
            $null = Set-CsPhoneNumberAssignment -Identity $user.UserPrincipalName -PhoneNumber $user.BusinessPhones -PhoneNumberType $TPNM_PhoneNumberType -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to set phone number for user $($user.UserPrincipalName)"
            continue
        }
        Write-DebugToOutputStream -Message "...OK"
    }

    # Check whether the correct Voice Routing Policy is already assigned
    if ($teamsUser.OnlineVoiceRoutingPolicy -ne $TPNMAuto_TeamsVoiceRoutingPolicy) {
        Write-DebugToOutputStream -Message "Assigning Voice Routing Policy '$TPNMAuto_TeamsVoiceRoutingPolicy' to user '$($user.UserPrincipalName)'..."
        try {
            # Assign Voice Routing Policy to user
            $null = Grant-CsOnlineVoiceRoutingPolicy -Identity $user.UserPrincipalName -PolicyName $TPNMAuto_TeamsVoiceRoutingPolicy -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to assign Voice Routing Policy to user '$($user.UserPrincipalName)'"
            continue
        }
    }

    # Check whether the correct Dial Plan is already assigned
    if ($teamsUser.TenantDialPlan -ne $TPNMAuto_TeamsDialPlanPolicy) {
        Write-DebugToOutputStream -Message "Assigning Dial Plan '$TPNMAuto_TeamsDialPlanPolicy' to user '$($user.UserPrincipalName)'..."
        try {
            # Assign Dial Plan to user
            $null = Grant-CsTenantDialPlan -Identity $user.UserPrincipalName -PolicyName $TPNMAuto_TeamsDialPlanPolicy -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to assign Dial Plan to user '$($user.UserPrincipalName)'"
            continue
        }
        Write-DebugToOutputStream -Message "...OK"
    }
}

#endregion

#region Disconnect from Teams and Graph

# Disconnect from Teams
Write-DebugToOutputStream -Message 'Disconnecting from Teams...'
Disconnect-MicrosoftTeams
Write-DebugToOutputStream -Message '...OK'

# Disconnect from Azure
Write-DebugToOutputStream -Message 'Disconnecting from Azure...'
Disconnect-MgGraph
Write-DebugToOutputStream -Message '...OK'

#endregion