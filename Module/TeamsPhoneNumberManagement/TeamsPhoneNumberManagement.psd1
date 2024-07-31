@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'TeamsPhoneNumberManagement.psm1'
    
    # Version number of this module.
    ModuleVersion     = '1.1.1'
    
    # Supported PSEditions
    # CompatiblePSEditions = @()
    
    # ID used to uniquely identify this module
    GUID              = 'bb51b965-b8cf-44bd-875c-3f0229ed2123'
    
    # Author of this module
    Author            = 'Jamy Klotzsche'
    
    # Company or vendor of this module
    CompanyName       = ''
    
    # Copyright statement for this module
    Copyright         = '(c) Jamy Klotzsche. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description       = 'Custom module to manage Teams phone numbers. This module is used as part of the TeamsPhoneNumberManagement solution and provides the needed functions for the API based on an Azure Function App. This API has CRUD capabilities with database, which contains information about configured countries, departments, forbidden numbers (e.g. emergency telephone numbers), extension / phone ranges and already used phone numbers. The already used phone numbers include phone numbers used by Teams users as well as blocked phone numbers for certain devices.'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.2'
    
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules   = @(
        'Azure.Function.Tools',
        'Az.Accounts'
    )
    
    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @('bin\my.dll')
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    ScriptsToProcess  = @('.\internal\scripts\TPNMEnums.ps1')
    
    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        # Allocation
        'Add-TPNMAllocation',
        'Get-TPNMAllocation',
        'Remove-TPNMAllocation',
        'Request-TPNMAllocation',
        'Set-TPNMAllocation',

        # Country
        'Add-TPNMCountry',
        'Get-TPNMCountry',
        'Remove-TPNMCountry',
        'Set-TPNMCountry',

        # Database Connection
        'Connect-TPNMDatabase',
        'Disconnect-TPNMDatabase',
        'Get-TPNMDatabaseConnection',

        # Department
        'Add-TPNMDepartment',
        'Get-TPNMDepartment',
        'Remove-TPNMDepartment',
        'Set-TPNMDepartment',

        # Extension in use
        'Get-TPNMExtensionInUse',

        # Range
        'Add-TPNMExtRange',
        'Get-TPNMExtRange',
        'Remove-TPNMExtRange',
        'Set-TPNMExtRange',

        # Forbidden Extension
        'Add-TPNMForbidden',
        'Get-TPNMForbidden',
        'Remove-TPNMForbidden',
        'Set-TPNMForbidden'
    )
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    # CmdletsToExport   = '*'
    
    # Variables to export from this module
    # VariablesToExport = '*'
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    # AliasesToExport   = '*'
    
    # DSC resources to export from this module
    # DscResourcesToExport = @()
    
    # List of all modules packaged with this module
    # ModuleList = @()
    
    # List of all files packaged with this module
    # FileList = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{
    
        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()
    
            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement/blob/main/LICENSE'
    
            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement'
    
            # A URL to an icon representing this module.
            IconUri      = 'https://raw.githubusercontent.com/jklotzsche-msft/TeamsPhoneNumberManagement/main/Documentation/_images/TPNM_Logo.png'
    
            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/jklotzsche-msft/TeamsPhoneNumberManagement/Documentation/ReleaseNotes.md'
    
            # Prerelease string of this module
            # Prerelease = ''
    
            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false
    
            # External dependent modules of this module
            # ExternalModuleDependencies = @()
    
        } # End of PSData hashtable
    
    } # End of PrivateData hashtable
}