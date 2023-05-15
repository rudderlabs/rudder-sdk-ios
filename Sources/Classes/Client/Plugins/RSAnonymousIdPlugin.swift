//
//  RSAnonymousIdPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 02/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

// MARK: - iOS, tvOS, Catalyst

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import SystemConfiguration
import UIKit
#if !os(tvOS)
import WebKit
#endif
#endif

// MARK: - watchOS

#if os(watchOS)
import WatchKit
import Network
#endif

// MARK: - macOS

#if os(macOS)
import Cocoa
import WebKit
#endif

class RSAnonymousIdPlugin: RSPlatformPlugin {
    let type = PluginType.before
    var client: RSClient?
    
    var anonymousId: String?

    required init() {
#if os(iOS) || os(tvOS)
        anonymousId = UIDevice.current.identifierForVendor?.uuidString.lowercased()
#endif
#if os(watchOS)
        anonymousId = WKInterfaceDevice.current().identifierForVendor?.uuidString.lowercased()
#endif
#if os(macOS)
        anonymousId = macAddress(bsd: "en0")
#endif
    }
    
    private func macAddress(bsd: String) -> String? {
        let MAC_ADDRESS_LENGTH = 6
        let separator = ":"
        
        var length: size_t = 0
        var buffer: [CChar]
        
        let bsdIndex = Int32(if_nametoindex(bsd))
        if bsdIndex == 0 {
            return nil
        }
        let bsdData = Data(bsd.utf8)
        var managementInfoBase = [CTL_NET, AF_ROUTE, 0, AF_LINK, NET_RT_IFLIST, bsdIndex]
        
        if sysctl(&managementInfoBase, 6, nil, &length, nil, 0) < 0 {
            return nil
        }
        
        buffer = [CChar](unsafeUninitializedCapacity: length, initializingWith: {buffer, initializedCount in
            for x in 0..<length { buffer[x] = 0 }
            initializedCount = length
        })
        
        if sysctl(&managementInfoBase, 6, &buffer, &length, nil, 0) < 0 {
            return nil
        }
        
        let infoData = Data(bytes: buffer, count: length)
        let indexAfterMsghdr = MemoryLayout<if_msghdr>.stride + 1
        let rangeOfToken = infoData[indexAfterMsghdr...].range(of: bsdData)!
        let lower = rangeOfToken.upperBound
        let upper = lower + MAC_ADDRESS_LENGTH
        let macAddressData = infoData[lower..<upper]
        let addressBytes = macAddressData.map { String(format: "%02x", $0) }
        return addressBytes.joined(separator: separator)
    }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        workingMessage.anonymousId = anonymousId
        if var context = workingMessage.context {
            context[keyPath: "traits.anonymousId"] = anonymousId
            workingMessage.context = context
            client?.updateContext(context)
        }
        return workingMessage
    }
}

extension RSClient {
    /**
     API for setting unique identifier of every call.
     - Parameters:
        - anonymousId: Unique identifier of every event
     # Example #
     ```
     client.setAnonymousId("sample_anonymous_id")
     ```
     */
    @objc
    public func setAnonymousId(_ anonymousId: String) {
        guard anonymousId.isNotEmpty else {
            log(message: "anonymousId can not be empty", logLevel: .warning)
            return
        }
        if let anonymousIdPlugin = self.find(pluginType: RSAnonymousIdPlugin.self) {
            anonymousIdPlugin.anonymousId = anonymousId
        } else {
            let anonymousIdPlugin = RSAnonymousIdPlugin()
            anonymousIdPlugin.anonymousId = anonymousId
            add(plugin: anonymousIdPlugin)
        }
    }
}
