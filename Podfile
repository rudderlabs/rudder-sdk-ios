source 'https://github.com/CocoaPods/Specs.git'
workspace 'Rudder.xcworkspace'
use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'Rudder', :path => '.'
end

project 'Examples/RudderSampleAppObjC/RudderSampleAppObjC.xcodeproj'
project 'Examples/RudderSammpleAppSwift/RudderSammpleAppSwift.xcodeproj'
project 'Examples/RudderSampleApptvOSObjC/RudderSampleApptvOSObjC.xcodeproj'
project 'Examples/RudderSampleAppwatchOSObjC/RudderSampleAppwatchOSObjC.xcodeproj'

target 'RudderSampleAppObjC' do
    project 'Examples/RudderSampleAppObjC/RudderSampleAppObjC.xcodeproj'
    platform :ios, '10.0'
    shared_pods
    pod 'Rudder-Amplitude'
    pod 'Amplitude', '~> 7.2.0'
    pod 'Rudder-Braze'
    pod 'FirebaseMessaging'
end

target 'RudderSampleAppSwift' do
    project 'Examples/RudderSampleAppSwift/RudderSampleAppSwift.xcodeproj'
    platform :ios, '9.0'
    shared_pods
end

target 'RudderSampleApptvOSObjC' do
    project 'Examples/RudderSampleApptvOSObjC/RudderSampleApptvOSObjC.xcodeproj'
    platform :tvos, '10.0'
    shared_pods
end

target 'RudderSampleAppwatchOSObjC WatchKit Extension' do
  project 'Examples/RudderSampleAppwatchOSObjC/RudderSampleAppwatchOSObjC.xcodeproj'
  platform :watchos, '8.0'
  shared_pods
end
