# !/bin/bash -e
rm -rf archives/
rm -rf xcframeworks

xcodebuild archive \
    -workspace Rudder.xcworkspace \
    -scheme Rudder_iOS \
    -destination "generic/platform=iOS" \
    -archivePath "archives/Rudder-iOS" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO |
    xcpretty

xcodebuild archive \
    -workspace Rudder.xcworkspace \
    -scheme Rudder_iOS \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "archives/Rudder-iOS-simulator" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO |
    xcpretty

xcodebuild archive \
    -workspace Rudder.xcworkspace \
    -scheme Rudder_watchOS \
    -destination "generic/platform=watchOS" \
    -archivePath "archives/Rudder-watchOS" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO |
    xcpretty

xcodebuild archive \
    -workspace Rudder.xcworkspace \
    -scheme Rudder_watchOS \
    -destination "generic/platform=watchOS Simulator" \
    -archivePath "archives/Rudder-watchOS-simulator" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO |
    xcpretty

xcodebuild archive \
    -workspace Rudder.xcworkspace \
    -scheme Rudder_tvOS \
    -destination "generic/platform=tvOS" \
    -archivePath "archives/Rudder-tvOS" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO |
    xcpretty

xcodebuild archive \
    -workspace Rudder.xcworkspace \
    -scheme Rudder_tvOS \
    -destination "generic/platform=tvOS Simulator" \
    -archivePath "archives/Rudder-tvOS-simulator" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO |
    xcpretty

xcodebuild -create-xcframework \
    -archive archives/Rudder-iOS.xcarchive -framework Rudder.framework \
    -archive archives/Rudder-iOS-simulator.xcarchive -framework Rudder.framework \
    -archive archives/Rudder-watchOS.xcarchive -framework Rudder.framework \
    -archive archives/Rudder-watchOS-simulator.xcarchive -framework Rudder.framework \
    -archive archives/Rudder-tvOS.xcarchive -framework Rudder.framework \
    -archive archives/Rudder-tvOS-simulator.xcarchive -framework Rudder.framework \
    -output xcframeworks/Rudder.xcframework |
    xcpretty

xcodebuild -create-xcframework \
    -archive archives/Rudder-iOS.xcarchive -framework RudderKit.framework \
    -archive archives/Rudder-iOS-simulator.xcarchive -framework RudderKit.framework \
    -archive archives/Rudder-watchOS.xcarchive -framework RudderKit.framework \
    -archive archives/Rudder-watchOS-simulator.xcarchive -framework RudderKit.framework \
    -archive archives/Rudder-tvOS.xcarchive -framework RudderKit.framework \
    -archive archives/Rudder-tvOS-simulator.xcarchive -framework RudderKit.framework \
    -output xcframeworks/RudderKit.xcframework |
    xcpretty

xcodebuild -create-xcframework \
    -archive archives/Rudder-iOS.xcarchive -framework RSCrashReporter.framework \
    -archive archives/Rudder-iOS-simulator.xcarchive -framework RSCrashReporter.framework \
    -archive archives/Rudder-watchOS.xcarchive -framework RSCrashReporter.framework \
    -archive archives/Rudder-watchOS-simulator.xcarchive -framework RSCrashReporter.framework \
    -archive archives/Rudder-tvOS.xcarchive -framework RSCrashReporter.framework \
    -archive archives/Rudder-tvOS-simulator.xcarchive -framework RSCrashReporter.framework \
    -output xcframeworks/RSCrashReporter.xcframework |
    xcpretty

xcodebuild -create-xcframework \
    -archive archives/Rudder-iOS.xcarchive -framework MetricsReporter.framework \
    -archive archives/Rudder-iOS-simulator.xcarchive -framework MetricsReporter.framework \
    -archive archives/Rudder-watchOS.xcarchive -framework MetricsReporter.framework \
    -archive archives/Rudder-watchOS-simulator.xcarchive -framework MetricsReporter.framework \
    -archive archives/Rudder-tvOS.xcarchive -framework MetricsReporter.framework \
    -archive archives/Rudder-tvOS-simulator.xcarchive -framework MetricsReporter.framework \
    -output xcframeworks/MetricsReporter.xcframework |
    xcpretty
