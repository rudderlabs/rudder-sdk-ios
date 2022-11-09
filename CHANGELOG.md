# Changelog
All notable changes to this project will be documented in this file.

## Version - 2.0.0 - 2022-05-26
### Added
- Releasing Rudder Version 2.

## Version - 2.1.0 - 2022-06-09
### Fix
- `flush` API enhancement & fix.

## Version - 2.2.0 - 2022-07-06
### Added
- `subscribe` and `startTrial` in `RSEvents.LifeCycle`.
- `promotionName` in `RSKeys.Ecommerce`.
- `postalCode`, `state` and `street` in `RSKeys.Identify.Address`.
- `name`, `id`, `industry`, `employeeCount`, and `plan` in `RSKeys.Identify.Company`.
- `description` in `RSKeys.Others`.
### Fix
- Prevent blocking of main thread for periodic `flush`.
- Remove retain cycles.

## Version - 2.2.1 - 2022-07-07
### Fix
- Missing `properties.name` in screen calls.

## Version - 2.2.2 - 2022-07-08
### Fix
- Missing `properties.name` in screen calls for device modes.

## Version - 2.2.3 - 2022-07-14
### Fix
- [Bugfix] `RSClient` no longer blocks the main thread in `checkServerConfig()`
