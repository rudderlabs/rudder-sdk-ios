//
//  AppDelegate.swift
//  SampleSwift-macOS
//
//  Created by Pallab Maiti on 31/05/22.
//

import Cocoa
import Rudder

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let config: RSConfig = RSConfig(writeKey: "1wvsoF3Kx2SczQNlx1dvcqW9ODW")
            .dataPlaneURL("https://rudderstacz.dataplane.rudderstack.com")
            .loglevel(.debug)
            .trackLifecycleEvents(true)
            .recordScreenViews(false)
        
        RSClient.sharedInstance().configure(with: config)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

