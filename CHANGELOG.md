# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [1.14.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.13.2...v1.14.0) (2023-04-19)


### Features

* added support for device mode transformations ([#160](https://github.com/rudderlabs/rudder-sdk-ios/issues/160)) ([9f145eb](https://github.com/rudderlabs/rudder-sdk-ios/commit/9f145eb2c16ec8a83bc120a0788b94b294148241))

### [1.13.2](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.13.1...v1.13.2) (2023-04-12)


### Bug Fixes

* restricted nil assign of dataPlaneUrl and controlPlaneUrl ([#307](https://github.com/rudderlabs/rudder-sdk-ios/issues/307)) ([0e28b6f](https://github.com/rudderlabs/rudder-sdk-ios/commit/0e28b6f6f3539837608840d61fc7bf453097809f))

### [1.13.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.13.0...v1.13.1) (2023-04-11)


### Bug Fixes

* correct the width and height properties ([#302](https://github.com/rudderlabs/rudder-sdk-ios/issues/302)) ([98d5b55](https://github.com/rudderlabs/rudder-sdk-ios/commit/98d5b55de4ae5f5da5f15ab1954c1b628ced3465))

## [1.13.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.12.1...v1.13.0) (2023-03-27)


### Features

* made reset and identify api's synchronous to reflect the data immediately ([#284](https://github.com/rudderlabs/rudder-sdk-ios/issues/284)) ([6047fc6](https://github.com/rudderlabs/rudder-sdk-ios/commit/6047fc6a7a2d260edc49e6d6c3ea219b5392f95c))


### 1.13.0.beta.1 (2023-03-22)

### Features
* Device Mode Transformations


### [1.12.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.12.0...v1.12.1) (2023-03-21)


### Bug Fixes

* swift package manager umbrella header warning ([041805c](https://github.com/rudderlabs/rudder-sdk-ios/commit/041805cb1e4389b9db821f6549bba3728857acd6))

## [1.12.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.11.1...v1.12.0) (2023-03-02)


### Features

* added consent support for cloud mode ([22745d9](https://github.com/rudderlabs/rudder-sdk-ios/commit/22745d90e87a137833549c45652d083b6d99c845))


## [1.11.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.11.0...v1.11.1) (2023-02-28)


### Bug Fixes

* semantic versioning issue ([c329286](https://github.com/rudderlabs/rudder-sdk-ios/commit/c329286dda04010207254833df4738d5cb3d5612))
* swift package manager build issue ([320a600](https://github.com/rudderlabs/rudder-sdk-ios/commit/320a60098ddb983f02c1280c48ff985783e51fc8))

## [1.11.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.9.0...v1.11.0) (2023-02-21)


### Features

* added consent support ([c39786c](https://github.com/rudderlabs/rudder-sdk-ios/commit/c39786c13da1cec0ffe49308e4c686a4471ccefc))
* log error message for empty writeKey & dataPlaneUrl ([f7887d8](https://github.com/rudderlabs/rudder-sdk-ios/commit/f7887d82cefbce54b9fc07c53caeb3b23b8c77d8))


### Bug Fixes

* handled corrupt data of database ([fd67568](https://github.com/rudderlabs/rudder-sdk-ios/commit/fd67568bd13d6f4cf5704b598eb2343ba886cb04))

## [1.10.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.8.0...v1.10.0) (2023-02-09)


### Features

* added consent support ([c39786c](https://github.com/rudderlabs/rudder-sdk-ios/commit/c39786c13da1cec0ffe49308e4c686a4471ccefc))
* added Data Residency support ([#203](https://github.com/rudderlabs/rudder-sdk-ios/issues/203)) ([3b2b933](https://github.com/rudderlabs/rudder-sdk-ios/commit/3b2b933fabb8568f80217d2367ed8ce3e7c41efe))

## [1.9.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.8.0...v1.9.0) (2023-02-02)


### Features

* added Data Residency support ([#203](https://github.com/rudderlabs/rudder-sdk-ios/issues/203)) ([3b2b933](https://github.com/rudderlabs/rudder-sdk-ios/commit/3b2b933fabb8568f80217d2367ed8ce3e7c41efe))

## [1.8.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.7.1...v1.8.0) (2022-12-08)


### Features

* remove timestamp from messageId ([a0f89fc](https://github.com/rudderlabs/rudder-sdk-ios/commit/a0f89fcb20d0bb0c76919d78a3e19585e489bbed))


### Bug Fixes

* initialise `eventFiltering` object even when `destinations` is empty ([3a5c1c4](https://github.com/rudderlabs/rudder-sdk-ios/commit/3a5c1c412c63c4ca0a9c57538135fbfde238a69a))

### [1.7.2](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.7.1...v1.7.2) (2022-11-17)


### Bug Fixes

* initialise `eventFiltering` object even when `destinations` is empty ([3a5c1c4](https://github.com/rudderlabs/rudder-sdk-ios/commit/3a5c1c412c63c4ca0a9c57538135fbfde238a69a))

### 1.7.1 (2022-11-04)


### Bug Fixes

* session is generating on reset api even when session is disabled ([7585f3a](https://github.com/rudderlabs/rudder-sdk-ios/commit/7585f3a1ad6eb7e36b233d870c61774e1326e44e))

### [1.7.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.6.4...v1.7.0) (2022-09-22)


### Feature

* Added session tracking.

### [1.6.4](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.6.3...v1.6.4) (2022-08-24)


### Bug Fixes

* Made `context.device.attTrackingStatus` independent of `context.device.advertisingId` so that the att Tracking status would be sent along in the payload even if the advertisingId is nil as opposed to prior.
* Handled an edge case where in if the RSOption objects are created even before the SDK was initialized, the queue it was trying to dispatch a task on is nil and resulted in crash.

### [1.6.3](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.6.2...v1.6.3) (2022-07-13)


### Bug Fixes

* Removed HardCoded Status values of Bluetooth, Cellular, Wifi from the context object of the event payload

### [1.6.2](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.6.1...v1.6.2) (2022-06-28)


### Bug Fixes

* Fixed additional / in the url for both control plane url and dataplaneurl as a result of which the network requests to both control plane and data plane url are being failed.

### [1.6.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.6.0...v1.6.1) (2022-06-22)


### Bug Fixes

* Included Build Number as well in the life cycle events Application Installed & Application Updated.
* Accepting path as well as part of the url for both control plane url and data plane url.

### [1.6.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.5.3...v1.6.0) (2022-05-06)


### Feature

* Flush API

### [1.5.3](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.5.2...v1.5.3) (2022-04-07)


### Bug Fixes

* Improper timestamp issue

### [1.5.2](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.5.1...v1.5.2) (2022-02-16)


### Bug Fixes

* Thread issue

### [1.5.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.5.0...v1.5.1) (2022-02-11)


### Bug Fixes

* Removed warnings

### [1.5.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.4.2...v1.5.0) (2022-01-20)


### Feature

* Added Support for Client Side Event Filtering for Device Mode Destinations

### [1.4.2](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.4.1...v1.4.2) (2022-01-12)


### Bug Fixes

* Fixed Memory leak issue while replaying events to the device mode factories once they are initialized.

### [1.4.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.3.1...v1.4.1) (2022-01-11)


### Feature

* Added support for additional background run time through configuration on watchOS as well along with iOS, tvOS.

### Bug Fixes

* Fixed building issue via Carthage for watchOS & tvOS.

### [1.3.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.2.2...v1.3.1) (2021-12-30)


### Feature

* Added support for watchOS.
* Added support for event sending from background mode.

### Bug Fixes

* Optimized the GDPR by removing the un-necessary checks in the life cycle events tracking code.

### [1.2.2](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.2.1...v1.2.2) (2021-12-13)


### Bug Fixes

* Added logic to filter out the property which are not set for Application Opened event. 

### [1.2.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.2.0...v1.2.1) (2021-11-25)


### Bug Fixes

* Method 'setAnonymousId' marked as deprecated method

### [1.2.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.1.5...v1.2.0) (2021-11-24)


### Feature

* Added Support for Setting device token before SDK initialization as well.

### [1.1.5](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.1.4...v1.1.5) (2021-11-18)


### Bug Fixes

* Timestamp as Gregorian Calender.

### [1.1.4](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.1.3...v1.1.4) (2021-11-08)


### Bug Fixes

* Removed User agent
