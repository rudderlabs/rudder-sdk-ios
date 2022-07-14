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

## Version - 1.2.2 - 2021-12-06
### Changed
- Added logic to filter out the property which are not set for Application Opened event. 

## Version - 1.3.0 - 2021-12-29
### Additions
- Added support for additional background run time through configuration on iOS, tvOS.
- Added watchOS as a supported platform.

## Version - 1.3.1 - 2021-12-30
### Changed
- Optimized the GDPR by removing the un-necessary checks in the life cycle events tracking code.

## Version - 1.4.0 - 2021-12-29
### Additions
- Added support for additional background run time through configuration on watchOS as well along with iOS, tvOS.

## Version - 1.4.1 - 2022-01-11
### Fix
- Fixed building issue via Carthage for watchOS & tvOS.

## Version - 1.4.2 - 2022-01-12
### Fix
- Fixed Memory leak issue while replaying events to the device mode factories once they are initialized.

## Version - 1.5.0 - 2022-01-20
### Feature

- Added Support for Client Side Event Filtering for Device Mode Destinations

## Version - 1.5.1 - 2022-02-11
### Fix
- Removed warnings

## Version - 1.5.2 - 2022-02-16
### Fix
- Thread issue

## Version - 1.5.3 - 2022-03-07
### Fix
- Improper timestamp issue

## Version - 1.6.0 - 2022-05-04
### Feature
- Flush API

## Version - 1.6.1 - 2022-06-20
- Included Build Number as well in the life cycle events Application Installed & Application Updated.
- Accepting path as well as part of the url for both control plane url and data plane url.

## Version - 1.6.2 - 2022-06-28
- Fixed additional / in the url for both control plane url and dataplaneurl as a result of which the network requests to both control plane and data plane url are being failed.

## Version - 1.6.3 - 2022-07-11
- Removed HardCoded Status values of Bluetooth, Cellular, Wifi from the context object of the event payload

## Version - 1.7.0 - 2022-07-14
### Feature
- Added session tracking.
