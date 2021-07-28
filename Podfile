workspace 'Rudder.xcworkspace'
platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'Rudder', :path => 'Rudder/'
end

project 'RudderSampleAppObjC/RudderSampleAppObjC.xcodeproj'
project 'RudderSammpleAppSwift/RudderSammpleAppSwift.xcodeproj'

target 'RudderSampleAppObjC' do
    project 'RudderSampleAppObjC/RudderSampleAppObjC.xcodeproj'
    shared_pods
    target 'RudderSampleAppObjC_Tests' do
        inherit! :search_paths
        pod 'FBSnapshotTestCase'
    end
end

target 'RudderSampleAppSwift' do
    project 'RudderSampleAppSwift/RudderSampleAppSwift.xcodeproj'
    shared_pods
end
