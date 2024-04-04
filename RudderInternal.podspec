require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name             = 'RudderInternal'
  s.version          = package['version']
  s.summary          = "Rudder Swift SDK for iOS, tvOS, watchOS & macOS."
  s.description      = <<-DESC
  Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
                       DESC

  s.homepage         = "https://www.rudderstack.com/"
  s.license          = { :type => "LSv2", :file => "LICENSE" }
  s.authors          = { "Pallab Maiti" => "pallab@rudderstack.com",
                         "Sai Venkat Desu" => "venkat@rudderstack.com",
                         "Abhishek Pandey" => "abhishek@rudderstack.com" }
  s.source           = { :git => "https://github.com/rudderlabs/rudder-sdk-ios.git", :tag => "v#{s.version}" }

  s.swift_version = '5.3'
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '11.0'
  s.watchos.deployment_target = '7.0'
  s.osx.deployment_target = '10.13'
  
  s.source_files = 'RudderInternal/Sources/**/*.swift'
  
end
