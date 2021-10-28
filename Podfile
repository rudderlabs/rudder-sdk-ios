workspace 'Rudder.xcworkspace'
use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'Rudder', :path => 'Rudder/'
end

project 'RudderSampleAppObjC/RudderSampleAppObjC.xcodeproj'
project 'RudderSammpleAppSwift/RudderSammpleAppSwift.xcodeproj'
project 'RudderSampleApptvOSObjC/RudderSampleApptvOSObjC.xcodeproj'
project 'Rudder/Rudder.xcodeproj'

target 'RudderSampleAppObjC' do
    project 'RudderSampleAppObjC/RudderSampleAppObjC.xcodeproj'
    platform :ios, '9.0'
    shared_pods
end

target 'RudderSampleAppSwift' do
    project 'RudderSampleAppSwift/RudderSampleAppSwift.xcodeproj'
    platform :ios, '9.0'
    shared_pods
end

target 'RudderSampleApptvOSObjC' do
    project 'RudderSampleApptvOSObjc/RudderSampleApptvOSObjC.xcodeproj'
    platform :tvos, '9.0'
    shared_pods
end
