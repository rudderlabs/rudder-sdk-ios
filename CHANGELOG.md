# Changelog
All notable changes to this project will be documented in this file.

## Version - 1.0 - 2020-02-26
### Added
- Automatic App Life cycle events tracking is added. `Application Installed`, `Application Updated`, `Application Opened`, `Application Backgrounded`. It is tracked by default and can be turned off using `RudderConfig`.
- Automatic Screen view events tracking is added. All Activities are tracked at `onStart` of the `Activity`. It is turned off by default. It can be turned on using `RudderConfig`.
- Added support for ECommerce events from the SDK. Different builders for important events are added.
- A new header `anonymousId` is added to the request to `data-plane` along with `writeKey` to handle sticky-session at the server.
- Added support for open-source config generator.
### Changed
- Pod name from `RudderSDKCore` to `Rudder` and main header file from `RudderSDKCore.h` to `Rudder.h`. Please follow the doumentation page for more information.
- New field `userId` is supported to make it more compliant under `context->traits` for `identify` and all successive calls. Old filed for developer identification i.e. `id` is still supported. 