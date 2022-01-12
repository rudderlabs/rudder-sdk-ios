Pod::Spec.new do |s|
  s.name             = 'Rudder'
  s.version          = "1.4.2"
  s.summary          = "Privacy and Security focused Segment-alternative. iOS ,tvOS and watchOS SDK"
  s.description      = <<-DESC
  Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
                       DESC

  s.homepage         = "https://github.com/rudderlabs/rudder-sdk-ios"
  s.license          = { :type => "Apache", :file => "LICENSE" }
  s.author           = { "Rudderstack" => "arnab@rudderlabs.com" }
  s.source           = { :git => "https://github.com/rudderlabs/rudder-sdk-ios.git", :tag => "v#{s.version}" }

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '4.0'
  
  s.source_files = 'Sources/**/*.{h,m}'
end
