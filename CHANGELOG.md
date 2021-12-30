# Changelog
All notable changes to this project will be documented in this file.

## Version - 1.1.4 - 2021-11-08
### Added
- Automatic App Life cycle events tracking is added. `Application Installed`, `Application Updated`, `Application Opened`, `Application Backgrounded`. It is tracked by default and can be turned off using `RudderConfig`.
- Automatic Screen view events tracking is added. All `ViewControllers` are tracked once you turn on using `RudderConfig`
- Added support for ECommerce events from the SDK. Different builders for important events are added.
- A new header `anonymousId` is added to the request to `data-plane` along with `writeKey` to handle sticky-session at the server.
- Added support for open-source config generator.
- Added GDPR support.
- Added tvOS support.
### Changed
- Pod name from `RudderSDKCore` to `Rudder` and main header file from `RudderSDKCore.h` to `Rudder.h`. Please follow the doumentation page for more information.
- New field `userId` is supported to make it more compliant under `context->traits` for `identify` and all successive calls. Old filed for developer identification i.e. `id` is still supported.
- Removed User agent
## Version - 1.1.5 - 2021-11-18
### Changed
- Bugfix - timestamp as Gregorian Calender.

## Version - 1.2.1 - 2021-11-22
### Changed
- Added Support for Setting device token before SDK initialization as well.

##Version - 1.2.2 - 2021-12-06
### Changed
- Added logic to filter out the property which are not set for Application Opened event. 

##Version - 1.3.0 - 2021-12-29
### Additions
- Added support for additional background run time through configuration.
- Added watchOS as a supported platform.

