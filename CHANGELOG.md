# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [1.20.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.19.2...v1.20.0) (2023-09-19)


### Features

* error reporter ([#380](https://github.com/rudderlabs/rudder-sdk-ios/issues/380)) ([5683ccb](https://github.com/rudderlabs/rudder-sdk-ios/commit/5683ccb42eb9d5445efa69ad8cf1e52ca8dad195))
* get session_id ([#385](https://github.com/rudderlabs/rudder-sdk-ios/issues/385)) ([7a590f0](https://github.com/rudderlabs/rudder-sdk-ios/commit/7a590f05fd50e48155e0e2bc50ef44e491ca9475))
* revamped db encryption ([#388](https://github.com/rudderlabs/rudder-sdk-ios/issues/388)) ([0efaffa](https://github.com/rudderlabs/rudder-sdk-ios/commit/0efaffa750656eff6f589184e2fc6052d134ed50))


### Bug Fixes

* db encryption improvements ([#381](https://github.com/rudderlabs/rudder-sdk-ios/issues/381)) ([82504dd](https://github.com/rudderlabs/rudder-sdk-ios/commit/82504ddc6f56a7009d94bd4a28e672bd63f10ebc))
* ensure batch array in the request payload is never empty ([#387](https://github.com/rudderlabs/rudder-sdk-ios/issues/387)) ([7e7a92a](https://github.com/rudderlabs/rudder-sdk-ios/commit/7e7a92a4f362dd757be4ca033af863f1aaa1c0bf))
* SPM build error due to use of unsafe flags ([#384](https://github.com/rudderlabs/rudder-sdk-ios/issues/384)) ([d5edb2e](https://github.com/rudderlabs/rudder-sdk-ios/commit/d5edb2e380483666c66243ad576f7c2a05402697))

### [1.19.2](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.19.1...v1.19.2) (2023-08-28)


### Bug Fixes

* db encryption improvements ([#375](https://github.com/rudderlabs/rudder-sdk-ios/issues/375)) ([18ba785](https://github.com/rudderlabs/rudder-sdk-ios/commit/18ba7856d918b15d36f0e7c8916dd4d57f15b51b))
* renamed extern string of metrics ([#376](https://github.com/rudderlabs/rudder-sdk-ios/issues/376)) ([902d77f](https://github.com/rudderlabs/rudder-sdk-ios/commit/902d77fe34d99e0e7792804b8d3a28bcbfc27378))
* spm build is failing for missing dependency ([#373](https://github.com/rudderlabs/rudder-sdk-ios/issues/373)) ([d478c23](https://github.com/rudderlabs/rudder-sdk-ios/commit/d478c23de1e671d2d112ab1ab8181d55064ed427))

### [1.19.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.19.0...v1.19.1) (2023-08-23)


### Bug Fixes

* header not found issue on cross platforms ([#369](https://github.com/rudderlabs/rudder-sdk-ios/issues/369)) ([b9ba353](https://github.com/rudderlabs/rudder-sdk-ios/commit/b9ba353b81744962fd3f2321127c9db636549d6f))

## [1.19.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.18.0...v1.19.0) (2023-08-22)


### Features

* encrypt database ([#359](https://github.com/rudderlabs/rudder-sdk-ios/issues/359)) ([db17361](https://github.com/rudderlabs/rudder-sdk-ios/commit/db1736171bb3746f8ac33e321e92f0637d358871))
* made deviceId collection configurable and de-coupled anonymousId and deviceId ([#361](https://github.com/rudderlabs/rudder-sdk-ios/issues/361)) ([fbd434a](https://github.com/rudderlabs/rudder-sdk-ios/commit/fbd434a6d39eb5f15b62c0975edd3b5ccc5d732b))

## [1.18.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.17.0...v1.18.0) (2023-08-08)


### Features

* metrics reporter ([#347](https://github.com/rudderlabs/rudder-sdk-ios/issues/347)) ([ce638a6](https://github.com/rudderlabs/rudder-sdk-ios/commit/ce638a6d8cd395926336901ef3a2e1bfff860ebe))

## [1.17.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.16.1...v1.17.0) (2023-08-02)


### Features

* enhanced support for dmt with source config changes as well as retrying with backoff ([#351](https://github.com/rudderlabs/rudder-sdk-ios/issues/351)) ([1ee4807](https://github.com/rudderlabs/rudder-sdk-ios/commit/1ee480742cd2780e8e16ddaf0b44b0b0c97ff5ae))


### Bug Fixes

* event not getting removed from DB and certain processing issue ([#340](https://github.com/rudderlabs/rudder-sdk-ios/issues/340)) ([54d210c](https://github.com/rudderlabs/rudder-sdk-ios/commit/54d210c083d45779c53e1a21659ee71d2ad75b9f))
* fixed application installed and updated getting triggered in-correctly ([#345](https://github.com/rudderlabs/rudder-sdk-ios/issues/345)) ([cbdf123](https://github.com/rudderlabs/rudder-sdk-ios/commit/cbdf12383fe19de918a42694f22d462d2454294a))
* fixed automatic session not getting cleared on dynamically disabling track life cycle events ([#344](https://github.com/rudderlabs/rudder-sdk-ios/issues/344)) ([0b580d9](https://github.com/rudderlabs/rudder-sdk-ios/commit/0b580d9203ad47db8c9d263c7020b16c1f193f6e))
* replay message queue dumping logic  ([#348](https://github.com/rudderlabs/rudder-sdk-ios/issues/348)) ([307e730](https://github.com/rudderlabs/rudder-sdk-ios/commit/307e7304cb9f385dcdc77943e05ee75c79c66006))

### [1.16.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.16.0...v1.16.1) (2023-07-31)


### Bug Fixes

* event not getting removed from DB and certain processing issue ([#340](https://github.com/rudderlabs/rudder-sdk-ios/issues/340)) ([54d210c](https://github.com/rudderlabs/rudder-sdk-ios/commit/54d210c083d45779c53e1a21659ee71d2ad75b9f))
* fixed application installed and updated getting triggered in-correctly ([#345](https://github.com/rudderlabs/rudder-sdk-ios/issues/345)) ([cbdf123](https://github.com/rudderlabs/rudder-sdk-ios/commit/cbdf12383fe19de918a42694f22d462d2454294a))
* fixed automatic session not getting cleared on dynamically disabling track life cycle events ([#344](https://github.com/rudderlabs/rudder-sdk-ios/issues/344)) ([0b580d9](https://github.com/rudderlabs/rudder-sdk-ios/commit/0b580d9203ad47db8c9d263c7020b16c1f193f6e))
* replay message queue dumping logic  ([#348](https://github.com/rudderlabs/rudder-sdk-ios/issues/348)) ([307e730](https://github.com/rudderlabs/rudder-sdk-ios/commit/307e7304cb9f385dcdc77943e05ee75c79c66006))

## [1.16.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.15.1...v1.16.0) (2023-06-08)


### Features

* added support for gzip ([#325](https://github.com/rudderlabs/rudder-sdk-ios/issues/325)) ([2e1fba0](https://github.com/rudderlabs/rudder-sdk-ios/commit/2e1fba097b7f288047b5593fe2da4244dbf45ea6))

### [1.15.1](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.15.0...v1.15.1) (2023-05-12)


### Bug Fixes

* fixed insert sql statements to support sqlite versions less than 3.35.0 ([#318](https://github.com/rudderlabs/rudder-sdk-ios/issues/318)) ([4ed5cc2](https://github.com/rudderlabs/rudder-sdk-ios/commit/4ed5cc20e0bb0dd34d11a07100685584958e8f32))

## [1.15.0](https://github.com/rudderlabs/rudder-sdk-ios/compare/v1.14.0...v1.15.0) (2023-05-09)


### Features

* handled retrieving carrier names as per different iOS versions ([a81e3a2](https://github.com/rudderlabs/rudder-sdk-ios/commit/a81e3a2de7a10f5d16d8632db97a301f10920631))

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
