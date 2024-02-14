//
//  SwiftUI_iOSApp.swift
//  SwiftUI-iOS
//
//  Created by Pallab Maiti on 11/02/24.
//

import SwiftUI
import Rudder

@main
struct SwiftUI_iOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(client: RSClient.client)
        }
    }
}

extension RSClient {
    static var client: RSClient {
        let path = Bundle.main.path(forResource: "RudderConfig_1", ofType: "plist")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let rudderConfig = try! PropertyListDecoder().decode(RudderConfig.self, from: data)
        
        let config: Rudder.Configuration = Configuration(
            writeKey: rudderConfig.WRITE_KEY,
            dataPlaneURL: rudderConfig.DEV_DATA_PLANE_URL
        )!
            .controlPlaneURL(rudderConfig.DEV_CONTROL_PLANE_URL)
            .logLevel(.verbose)
            .trackLifecycleEvents(true)
            .sleepTimeOut(5)
            .gzipEnabled(false)
            .flushQueueSize(0)
        
        return RSClient.initialize(with: config)
    }
}
