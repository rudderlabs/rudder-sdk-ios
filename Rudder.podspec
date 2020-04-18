Pod::Spec.new do |s|
  s.name             = 'Rudder'
  s.version          = "1.0.1-patch.3"
  s.summary          = "Privacy and Security focused Segment-alternative. iOS SDK"
  s.description      = <<-DESC
  Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
                       DESC

  s.homepage         = "https://github.com/rudderlabs/rudder-sdk-ios"
  s.license          = { :type => "Apache", :file => "LICENSE" }
  s.author           = { "Rudderstack" => "arnab@rudderlabs.com" }
  s.platform         = :ios, "9.0"
  s.source           = { :git => "https://github.com/rudderlabs/rudder-sdk-ios.git", :commit => "7d36baf7f5b2cd691450b76dc1920f3744ec0a63" }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Rudder/Classes/**/*'
end
