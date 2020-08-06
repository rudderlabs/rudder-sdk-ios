Pod::Spec.new do |s|
  s.name             = 'Rudder'
  s.version          = "1.0.3-patch.4"
  s.summary          = "Privacy and Security focused Segment-alternative. iOS SDK"
  s.description      = <<-DESC
  Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
                       DESC

  s.homepage         = "https://github.com/rudderlabs/rudder-sdk-ios"
  s.license          = { :type => "Apache", :file => "LICENSE" }
  s.author           = { "Rudderstack" => "arnab@rudderlabs.com" }
  s.platform         = :ios, "9.0"
  s.source           = { :git => "https://github.com/rudderlabs/rudder-sdk-ios.git", :commit => "08d80ce981b59abd9ae90e3821d30f0c2dde7f9f" }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Rudder/Classes/**/*'
end
