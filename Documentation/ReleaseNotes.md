# Release Notes

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
