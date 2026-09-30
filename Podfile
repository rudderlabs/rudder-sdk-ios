# source 'https://github.com/rudderlabs/Specs.git'
workspace 'Rudder.xcworkspace'
use_frameworks!
inhibit_all_warnings!
install! 'cocoapods', :warn_for_unused_master_specs_repo => false

def shared_pods
    pod 'Rudder', :path => '.'
end

target 'Rudder-iOS' do
    project 'Rudder.xcodeproj'
    platform :ios, '15.0'
    target 'RudderTests-iOS' do
        inherit! :search_paths
    end
end

target 'Rudder-tvOS' do
    project 'Rudder.xcodeproj'
    platform :tvos, '15.0'
    target 'RudderTests-tvOS' do
        inherit! :search_paths
    end
end

target 'Rudder-watchOS' do
    project 'Rudder.xcodeproj'
    platform :watchos, '9.0'
    target 'RudderTests-watchOS' do
        inherit! :search_paths
    end
end

target 'RudderSampleAppObjC' do
    project 'Examples/RudderSampleAppObjC/RudderSampleAppObjC.xcodeproj'
    platform :ios, '15.0'
    shared_pods
    pod 'SQLCipher', '~> 4.0'
end

target 'RudderSampleAppSwift' do
    project 'Examples/RudderSampleAppSwift/RudderSampleAppSwift.xcodeproj'
    platform :ios, '15.0'
    shared_pods
    pod 'SQLCipher', '~> 4.0'
end

target 'RudderSampleApptvOSObjC' do
    project 'Examples/RudderSampleApptvOSObjC/RudderSampleApptvOSObjC.xcodeproj'
    platform :tvos, '15.0'
    shared_pods
end

target 'RudderSampleAppwatchOSObjC WatchKit Extension' do
  project 'Examples/RudderSampleAppwatchOSObjC/RudderSampleAppwatchOSObjC.xcodeproj'
  platform :watchos, '9.0'
  shared_pods
end

post_install do |installer|
  # Xcode 26+ refuses deployment targets below iOS 15 / tvOS 15 / watchOS 8
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['TVOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end
