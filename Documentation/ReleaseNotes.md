# Release Notes

## Version 1.2.0

### Breaking Changes

- **Migrated from System.Data.SqlClient to Microsoft.Data.SqlClient library**: Updated the entire project to use Microsoft.Data.SqlClient instead of the legacy System.Data.SqlClient library. This change provides enhanced security and performance, cross-platform compatibility for .NET Framework 4.6.2, .NET 8.0, and .NET 9.0 across Windows, Unix, and multiple architectures (x64, x86, ARM64), future-proofing with the modern actively maintained SQL client library, automatic platform detection, and improved Azure integration with better compatibility for Azure SQL Database and managed identity authentication.

### Technical Details

The migration to Microsoft.Data.SqlClient involved:

- Adding Microsoft.Data.SqlClient DLL files for all supported platforms and architectures in the `bin` directory structure
- Creating a new initialization script that automatically detects the current .NET framework version, platform (Windows/Unix), and architecture (x64/x86/ARM64)
- Updating all database connection functions to use `Microsoft.Data.SqlClient.SqlConnection` instead of `System.Data.SqlClient.SqlConnection`
- Maintaining backward compatibility for existing PowerShell scripts and Function Apps

### Bug Fixes

- **Fixed PSTN number retrieval limitation in Update-TPNMDatabase.ps1**: Updated the automation runbook to handle Microsoft's cmdlet limitation changes (MC950880) where `Get-CsPhoneNumberAssignment` now returns a maximum of 1000 PSTN numbers per call. The script now retrieves PSTN numbers in chunks of 1000 using pagination with `Skip` parameter and merges the results to ensure all phone numbers are processed correctly.
- **Fixed Join-String separator issue in build process**: Specified the `-Separator` parameter in `Join-String` calls for timer trigger code and configuration generation in the Function App build script to prevent potential formatting issues.

### Other Improvements

- **Updated module version**: Bumped module version from 1.1.3 to 1.2.0 in the module manifest
- **Documentation updates**: Updated deployment documentation to reflect the deprecated `TPNMAuto_PhoneNumberAssigmentResultSize` parameter and explain the new chunked retrieval approach for PSTN numbers
- **Code formatting improvements**: Enhanced code readability and consistency across various scripts
- **Parameter deprecation notice**: Added clear documentation that `TPNMAuto_PhoneNumberAssigmentResultSize` parameter is deprecated but retained for backward

## Version 1.1.3

### Enhancements

- Add the `SqlConnectionTimeout` parameter to the `Connect-TPNMDatabase` function to allow users to specify the timeout for the SQL connection. Additionally, the default timeout has been increased to 30 seconds to prevent timeouts when connecting to the database.

### Breaking Changes

- Updated the `Connect-TPNMDatabase` function to use the `-AsSecureString` parameter of `Get-AzAccessToken`. This change is necessary to support the new version of the `Az` module in the future.

## Version 1.1.2

### Bug Fixes

- Fixed a bug where the `ResultSize` parameter wasn't set for sub-procedures of Request-TPNMAllocation. This resulted in the sub-procedures returning only 100 results instead of all results.

## Version 1.0.0

### New Features

- initial upload of the project

### Enhancements

- initial upload of the project

### Bug Fixes

- initial upload of the project

### Breaking Changes

- initial upload of the project

### Removed Features

- initial upload of the project

### Documentation Updates

- initial upload of the project. Please refer to the [README.md](../README.md) for more information.
