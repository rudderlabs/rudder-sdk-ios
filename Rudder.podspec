require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name             = 'Rudder'
  s.version          = package['version']
  s.summary          = "Privacy and Security focused Segment-alternative. iOS ,tvOS and watchOS SDK"
  s.description      = <<-DESC
  Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
                       DESC

  s.homepage         = "https://github.com/rudderlabs/rudder-sdk-ios"
  s.license          = { :type => "Apache", :file => "LICENSE" }
  s.author           = { "RudderStack" => "arnab@rudderlabs.com" }
  s.source           = { :git => "https://github.com/rudderlabs/rudder-sdk-ios.git", :tag => "v#{s.version}" }

  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '11.0'
  s.watchos.deployment_target = '7.0'
  
  s.swift_versions = ['5.0']
  
  s.frameworks = 'Foundation'
  
  s.source_files = 'Sources/**/*.{h,m}'
  
  s.dependency 'MetricsReporter', '1.1.1'
end
