# Changelog
All notable changes to this project will be documented in this file.

## Version - 1.0.0-beta.1 - 2022-03-23
### Added
- First beta release.

## Version - 1.0.0-beta.2 - 2022-03-23
### Fix
- Podspec homepage updated.

## Version - 1.0.0-beta.3 - 2022-04-01
### Added
- Public API exposed from RSServerConfig to fetch destination config by Codable.
`func getConfig<T: Codable>(forPlugin plugin: RSDestinationPlugin) -> T?`
- Public APIs for `track`.
`func track(_ eventName: String)`
`func track(_ eventName: String, properties: TrackProperties)`
`func track(_ eventName: String, properties: TrackProperties, option: RSOption)`
- Public APIs for `identify`.
`func identify(_ userId: String)`
`func identify(_ userId: String, traits: IdentifyTraits)`
`func identify(_ userId: String, traits: IdentifyTraits, option: RSOption)`
- Public APIs for `screen`.
`func screen(_ screenName: String)`
`func screen(_ screenName: String, category: String)`
`func screen(_ screenName: String, properties: ScreenProperties)`
`func screen(_ screenName: String, category: String, properties: ScreenProperties)`
`func screen(_ screenName: String, category: String, properties: ScreenProperties, option: RSOption)`
- Public APIs for `group`.
`func group(_ groupId: String)`
`func group(_ groupId: String, traits: GroupTraits)`
`func group(_ groupId: String, traits: GroupTraits, option: RSOption)`
- Public APIs for `alias`.
`func alias(_ newId: String)`
`func alias(_ newId: String, option: RSOption)`
- Added empty value check for `track()`, `identify()`, `screen()`, `group()`, `alias()`, `setAdvertisingId()`, `setAnonymousId()`, `setDeviceToken()` of `RSClient`.
- Added empty value check for `putExternalId()`, `putIntegration()`, `putCustomContext()` of `RSOption`.
- Sleep interval can not be less than 1 second.

### Fix
- Fixed `context.traits`.

## Version - 1.0.0-beta.4 - 2022-04-05
### Changed
- `RSECommerceConstants.swift` is `RSEventsAndKeys.swift` now.

## Version - 1.0.0-beta.5 - 2022-04-07
### Added
- Added `url` and `imageUrl` in `RSKeys.Ecommerce` list inside `RSEventsAndKeys.swift`.

## Version - 1.0.0-beta.6 - 2022-04-11
### Added
- Added `LifeCycleEvents`, `identify` and `screen` keys inside RSEventsAndKeys.swift.
- Added thread test cases in `RSThreadTests.swift`.
- Added database test cases in `RSDatabaseTests.swift`.

## Version - 2.0.0 - 2022-05-26
### Added
- Releasing Rudder Version 2.
