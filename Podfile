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
<<<<<<< HEAD
    platform :ios, '9.0'
    shared_pods
=======
    platform :ios, '11.0'
    shared_pods    
>>>>>>> 0ee2bfa (warnings removed)
end

target 'RudderSampleAppSwift' do
    project 'Examples/RudderSampleAppSwift/RudderSampleAppSwift.xcodeproj'
    platform :ios, '11.0'
    shared_pods
end

target 'RudderSampleApptvOSObjC' do
    project 'Examples/RudderSampleApptvOSObjC/RudderSampleApptvOSObjC.xcodeproj'
    platform :tvos, '11.0'
    shared_pods
end

target 'RudderSampleAppwatchOSObjC WatchKit Extension' do
  project 'Examples/RudderSampleAppwatchOSObjC/RudderSampleAppwatchOSObjC.xcodeproj'
  platform :watchos, '8.0'
  shared_pods
end

target 'RudderSampleAppOneTrustConsent' do
    project 'Examples/RudderSampleAppOneTrustConsent/RudderSampleAppOneTrustConsent.xcodeproj'
    platform :ios, '11.0'
    shared_pods
end
