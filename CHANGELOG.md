# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [2.2.7](https://github.com/rudderlabs/rudder-sdk-ios/compare/v2.1.0...v2.2.7) (2023-03-28)


### Bug Fixes

* config specified log level is not working ([aaa91d7](https://github.com/rudderlabs/rudder-sdk-ios/commit/aaa91d7683e3c48c548f9171710749a2c7c5a0ac))
* convert date into gregorian calendar ([#296](https://github.com/rudderlabs/rudder-sdk-ios/issues/296)) ([b9df566](https://github.com/rudderlabs/rudder-sdk-ios/commit/b9df5668e4cbf227c6f42c091b93da8118ab8947))
* enhance support for anonymousId for all supported platforms ([#257](https://github.com/rudderlabs/rudder-sdk-ios/issues/257)) ([60a0d70](https://github.com/rudderlabs/rudder-sdk-ios/commit/60a0d7042cf9a208f9dea1c2c6f677f335891cef))
* improper way of handling customContext ([9b2297e](https://github.com/rudderlabs/rudder-sdk-ios/commit/9b2297e2eca7cc0e694b142cda3f5507e80fff85))
* **macOS:** life cycle events were not tracking properly ([1733753](https://github.com/rudderlabs/rudder-sdk-ios/commit/17337536adb725411f9446c59bf99e2975975205))

### 2.2.6 (2023-01-31)


### Bug Fixes

* enhance support for anonymousId for all supported platforms ([#257](https://github.com/rudderlabs/rudder-sdk-ios/issues/257)) ([60a0d70](https://github.com/rudderlabs/rudder-sdk-ios/commit/60a0d7042cf9a208f9dea1c2c6f677f335891cef))
* improper way of handling customContext ([9b2297e](https://github.com/rudderlabs/rudder-sdk-ios/commit/9b2297e2eca7cc0e694b142cda3f5507e80fff85))

### [2.2.5](https://github.com/rudderlabs/rudder-sdk-ios/compare/v2.1.0...v2.2.5) (2022-11-16)


### Bug Fixes

* **macOS:** life cycle events were not tracking properly ([8879ff4](https://github.com/rudderlabs/rudder-sdk-ios/commit/8879ff40af77aabe3e3f842a52eb38f52576e83f))

### [2.2.4](https://github.com/rudderlabs/rudder-sdk-ios/compare/v2.2.3...v2.2.4) (2022-08-02)


### Feature

* moved `anonymousId` in `RSKeys.Identify.Traits`.
* moved `externalId` in `RSKeys.Other`.
* added Push Notification API `pushAuthorizationFromUserNotificationCenter`.

### [2.2.3](https://github.com/rudderlabs/rudder-sdk-ios/compare/v2.2.2...v2.2.3) (2022-07-14)


### Bug Fixes

* main thread is getting blocked on `checkServerConfig()` in `RSClient`.

### [2.2.2](https://github.com/rudderlabs/rudder-sdk-ios/compare/v2.2.1...v2.2.2) (2022-07-08)


### Bug Fixes

* added `properties.name` in screen calls for device modes.

### [2.2.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v2.2.0...v2.2.1) (2022-07-07)


### Bug Fixes

* added `properties.name` in screen calls.

### [2.2.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v2.1.0...v2.2.0) (2022-07-06)


### Feature

* added `subscribe` and `startTrial` in `RSEvents.LifeCycle`.
* added `promotionName` in `RSKeys.Ecommerce`.
* added `postalCode`, `state` and `street` in `RSKeys.Identify.Address`.
* added `name`, `id`, `industry`, `employeeCount`, and `plan` in `RSKeys.Identify.Company`.
* added `description` in `RSKeys.Others`.


### Bug Fixes

* main thread is getting blocked on `flush`.
* removed retain cycles.


### [2.1.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v2.0.0...v2.1.0) (2022-06-09)


### Bug Fixes

* `flush` API.

### 2.0.0 (2022-05-26)


### Feature

* release version 2.
