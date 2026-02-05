require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name             = 'Rudder'
  s.version          = package['version']
  s.summary          = "Privacy and Security focused Segment-alternative. iOS, tvOS, watchOS & macOS SDK"
  
  s.description = <<-DESC
  ⚠️ DEPRECATION NOTICE

  Version 2.x of the RudderStack iOS SDK is deprecated and is no longer actively maintained.

  Please migrate to the newer Swift-based iOS SDK for continued support, bug fixes, and new features.

  Swift SDK Repository:
  https://github.com/rudderlabs/rudder-sdk-swift

  Documentation:
  https://www.rudderstack.com/docs/sources/event-streams/sdks/swift-sdk/

  This SDK will be sunset in the near future. We strongly recommend migrating as soon as possible.


  ABOUT RUDDERSTACK

  Rudder is a platform for collecting, storing, and routing customer event data to dozens of tools. It is open-source, can run in your cloud environment (AWS, GCP, Azure, or your data center), and provides a powerful transformation framework to process event data on the fly.
  DESC

  s.homepage         = "https://github.com/rudderlabs/rudder-sdk-ios"
  s.license          = { :type => "Apache", :file => "LICENSE" }
  s.author           = { "RudderStack" => "sdk@rudderstack.com" }
  s.source           = { :git => "https://github.com/rudderlabs/rudder-sdk-ios.git", :tag => "v#{s.version}" }
  s.resource_bundles = { s.name => 'Sources/Resources/PrivacyInfo.xcprivacy' }

  s.deprecated = true

  s.swift_version = '5.3'
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '11.0'
  s.watchos.deployment_target = '7.0'
  s.osx.deployment_target = '10.13'
  
  s.frameworks = 'UserNotifications'
  
  s.source_files = 'Sources/**/*.swift'
end
