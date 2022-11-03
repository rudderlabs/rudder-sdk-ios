# Changelog
All notable changes to this project will be documented in this file.

### 1.7.0 (2022-07-14)


### Feature

* Added session tracking.

### 1.6.4 (2022-08-24)


### Bug Fixes

* Made `context.device.attTrackingStatus` independent of `context.device.advertisingId` so that the att Tracking status would be sent along in the payload even if the advertisingId is nil as opposed to prior.
* Handled an edge case where in if the RSOption objects are created even before the SDK was initialized, the queue it was trying to dispatch a task on is nil and resulted in crash.

### 1.6.3 (2022-07-11)


### Bug Fixes

* Removed HardCoded Status values of Bluetooth, Cellular, Wifi from the context object of the event payload

### 1.6.2 (2022-06-28)


### Bug Fixes

* Fixed additional / in the url for both control plane url and dataplaneurl as a result of which the network requests to both control plane and data plane url are being failed.

### 1.6.1 (2022-06-20)


### Bug Fixes

* Included Build Number as well in the life cycle events Application Installed & Application Updated.


### Bug Fixes

* Accepting path as well as part of the url for both control plane url and data plane url.

### 1.6.0 (2022-05-04)


### Feature

* Flush API

### 1.5.3 (2022-03-07)


### Bug Fixes

* Improper timestamp issue

### 1.5.2 (2022-02-16)


### Bug Fixes

* Thread issue

### 1.5.1 (2022-02-11)


### Bug Fixes

* Removed warnings

### 1.5.0 (2022-01-20)
### Feature

* Added Support for Client Side Event Filtering for Device Mode Destinations

### 1.4.2 (2022-01-12)


### Bug Fixes

* Fixed Memory leak issue while replaying events to the device mode factories once they are initialized.

### 1.4.1 (2022-01-11)


### Bug Fixes

* Fixed building issue via Carthage for watchOS & tvOS.

### 1.4.0 (2021-12-29)


### Feature

* Added support for additional background run time through configuration on watchOS as well along with iOS, tvOS.

### 1.3.1 (2021-12-30)


### Bug Fixes

* Optimized the GDPR by removing the un-necessary checks in the life cycle events tracking code.

### 1.3.0 (2021-12-29)


### Feature

* Added support for additional background run time through configuration on iOS, tvOS.
* Added watchOS as a supported platform.

### 1.2.2 (2021-12-06)


### Bug Fixes

* Added logic to filter out the property which are not set for Application Opened event. 

### 1.2.1 (2021-11-22)


### Bug Fixes

* Added Support for Setting device token before SDK initialization as well.

### 1.1.5 (2021-11-18)


### Bug Fixes

* Timestamp as Gregorian Calender.

### 1.1.4 (2021-11-08)


### Feature

* Automatic App Life cycle events tracking is added. `Application Installed`, `Application Updated`, `Application Opened`, `Application Backgrounded`. It is tracked by default and can be turned off using `RudderConfig`.
* Automatic Screen view events tracking is added. All `ViewControllers` are tracked once you turn on using `RudderConfig`
* Added support for ECommerce events from the SDK. Different builders for important events are added.
* A new header `anonymousId` is added to the request to `data-plane` along with `writeKey` to handle sticky-session at the server.
* Added support for open-source config generator.
* Added GDPR support.
* Added tvOS support.

### Bug Fixes

* Pod name from `RudderSDKCore` to `Rudder` and main header file from `RudderSDKCore.h` to `Rudder.h`. Please follow the doumentation page for more information.
* New field `userId` is supported to make it more compliant under `context->traits` for `identify` and all successive calls. Old filed for developer identification i.e. `id` is still supported.
* Removed User agent
