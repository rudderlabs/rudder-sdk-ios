workspace 'Rudder.xcworkspace'
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'Rudder', :path => 'Rudder/'
end

project 'RudderSampleAppObjC/RudderSampleAppObjC.xcodeproj'
project 'RudderSammpleAppSwift/RudderSammpleAppSwift.xcodeproj'
project 'Rudder/Rudder.xcodeproj'

target 'Rudder' do
    
end

target 'RudderSampleAppObjC' do
    project 'RudderSampleAppObjC/RudderSampleAppObjC.xcodeproj'
    shared_pods
end

target 'RudderSampleAppSwift' do
    project 'RudderSampleAppSwift/RudderSampleAppSwift.xcodeproj'
    shared_pods
end
