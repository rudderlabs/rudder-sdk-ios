source 'https://github.com/rudderlabs/Specs.git'
workspace 'Rudder.xcworkspace'
use_frameworks!
inhibit_all_warnings!
install! 'cocoapods', :warn_for_unused_master_specs_repo => false

def shared_pods
    pod 'Rudder', :path => '.'
end

def shared_utility_pods
    pod 'MetricsReporter'
    pod 'RudderKit'
    pod 'RSCrashReporter'
end

target 'Rudder-iOS' do
    project 'Rudder.xcodeproj'
    platform :ios, '12.0'
    shared_utility_pods
    target 'RudderTests-iOS' do
        inherit! :search_paths
        shared_utility_pods
    end
end

target 'Rudder-tvOS' do
    project 'Rudder.xcodeproj'
    platform :tvos, '11.0'
    shared_utility_pods
    target 'RudderTests-tvOS' do
        inherit! :search_paths
        shared_utility_pods
    end
end

target 'Rudder-watchOS' do
    project 'Rudder.xcodeproj'
    platform :watchos, '7.0'
    shared_utility_pods
    target 'RudderTests-watchOS' do
        inherit! :search_paths
        shared_utility_pods
    end
end

target 'RudderSampleAppObjC' do
    project 'Examples/RudderSampleAppObjC/RudderSampleAppObjC.xcodeproj'
    platform :ios, '12.0'
    shared_pods
    shared_utility_pods
    pod 'SQLCipher', '~> 4.0'
end

target 'RudderSampleAppSwift' do
    project 'Examples/RudderSampleAppSwift/RudderSampleAppSwift.xcodeproj'
    platform :ios, '12.0'
    shared_pods
    shared_utility_pods
    pod 'SQLCipher', '~> 4.0'
end

target 'RudderSampleApptvOSObjC' do
    project 'Examples/RudderSampleApptvOSObjC/RudderSampleApptvOSObjC.xcodeproj'
    platform :tvos, '11.0'
    shared_pods
    shared_utility_pods
end

target 'RudderSampleAppwatchOSObjC WatchKit Extension' do
  project 'Examples/RudderSampleAppwatchOSObjC/RudderSampleAppwatchOSObjC.xcodeproj'
  platform :watchos, '8.0'
  shared_pods
  shared_utility_pods
end
