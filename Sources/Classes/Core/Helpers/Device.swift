//
//  Device.swift
//  Rudder
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

internal struct ScreenSize {
    let width: Double
    let height: Double
    let density: Double
}

internal enum ConnectionType {
    case cellular
    case wifi
    case bluetooth
}

internal enum ConnectionStatus {
    case offline
    case online(ConnectionType)
    case unknown
}

internal class Device {
    var manufacturer: String {
        return "unknown"
    }
    
    var type: String {
        return "unknown"
    }
    
    var model: String {
        return "unknown"
    }
    
    var name: String {
        return "unknown"
    }
    
    var identifierForVendor: String? {
        return nil
    }
    
    var systemName: String {
        return "unknown"
    }
    
    var systemVersion: String {
        return ""
    }
    
    var screenSize: ScreenSize {
        return ScreenSize(width: 0, height: 0, density: 0)
    }
    
    var connection: ConnectionStatus {
        return ConnectionStatus.unknown
    }
    
    var carrier: String {
        return "unavailable"
    }
    
    var directory: FileManager.SearchPathDirectory {
        return .libraryDirectory
    }
    
    var directoryPath: URL {
        FileManager.default.urls(for: directory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]
    }
    
    static var current: Device = {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return Phone()
        #elseif os(macOS)
        return Mac()
        #elseif os(watchOS)
        return Watch()
        #else
        return Device()
        #endif
    }()
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import SystemConfiguration
import UIKit
#if !os(tvOS)
import WebKit
#endif
#if os(iOS)
import CoreTelephony
#endif

internal class Phone: Device {
    private let device = UIDevice.current
    
    override var manufacturer: String {
        return "Apple"
    }
    
    override var type: String {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "iPadOS"
        } else {
            return "iOS"
        }
#elseif os(tvOS)
        return "tvOS"
#elseif targetEnvironment(macCatalyst)
        return "macOS"
#else
        return "unknown"
#endif
    }
    
    override var model: String {
        return deviceModel()
    }
    
    override var name: String {
        return device.name
    }
    
    override var identifierForVendor: String? {
        return device.identifierForVendor?.uuidString.lowercased()
    }
    
    override var systemName: String {
        return device.systemName
    }
    
    override var systemVersion: String {
        device.systemVersion
    }
    
    override var screenSize: ScreenSize {
        let size = UIScreen.main.bounds.size
        return ScreenSize(width: Double(size.width), height: Double(size.height), density: UIScreen.main.scale)
    }
    
    override var connection: ConnectionStatus {
        return connectionStatus()
    }
    
    override var directory: FileManager.SearchPathDirectory {
#if os(tvOS)
        return .cachesDirectory
#else
        return .libraryDirectory
#endif
    }
    
    override var carrier: String {
#if os(iOS)
        return retrieveCarrierNames() ?? "unavailable"
#else
        return "unavailable"
#endif
        
    }
    
#if os(iOS)
    func retrieveCarrierNames() -> String? {
        if #available(iOS 16, *) {
            return nil
        } else {
            let networkInfo = CTTelephonyNetworkInfo()
            var carrierNames: [String] = []
            
            if let carriers = networkInfo.serviceSubscriberCellularProviders?.values {
                for carrierObj in carriers {
                    if let carrierName = carrierObj.carrierName, carrierName != "--" {
                        carrierNames.append(carrierName)
                    }
                }
            }
            if !carrierNames.isEmpty {
                let formattedCarrierNames = carrierNames.joined(separator: ", ")
                return formattedCarrierNames
            }
        }
        return nil
    }
#endif
    
    private func deviceModel() -> String {
        var hw: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&hw, 2, nil, &size, nil, 0)
        var hwMachine = [CChar](repeating: 0, count: Int(size))
        sysctl(&hw, 2, &hwMachine, &size, nil, 0)
        return String(cString: hwMachine)
    }
}

#endif

// MARK: - watchOS

#if os(watchOS)

import WatchKit
import Network

internal class Watch: Device {
    private let device = WKInterfaceDevice.current()
    
    override var manufacturer: String {
        return "Apple"
    }
    
    override var type: String {
        return "watchOS"
    }
    
    override var model: String {
        return deviceModel()
    }
    
    override var name: String {
        return device.name
    }
    
    override var identifierForVendor: String? {
        return device.identifierForVendor?.uuidString.lowercased()
    }
    
    override var systemName: String {
        return device.systemName
    }
    
    override var systemVersion: String {
        device.systemVersion
    }
    
    override var screenSize: ScreenSize {
        let size = device.screenBounds.size
        return ScreenSize(width: Double(size.width), height: Double(size.height), density: device.screenScale)
    }
    
    override var connection: ConnectionStatus {
        let path = NWPathMonitor().currentPath
        let interfaces = path.availableInterfaces
        
        var cellular = false
        var wifi = false
        for interface in interfaces {
            if interface.type == .cellular {
                cellular = true
            } else if interface.type == .wifi {
                wifi = true
            }
        }
        if cellular {
            return ConnectionStatus.online(.cellular)
        } else if wifi {
            return ConnectionStatus.online(.wifi)
        }
        return ConnectionStatus.unknown
    }
    
    private func deviceModel() -> String {
        var hw: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&hw, 2, nil, &size, nil, 0)
        var hwMachine = [CChar](repeating: 0, count: Int(size))
        sysctl(&hw, 2, &hwMachine, &size, nil, 0)
        return String(cString: hwMachine)
    }
    
}

#endif

// MARK: - macOS

#if os(macOS)

import Cocoa
import WebKit

internal class Mac: Device {
    private let device = ProcessInfo.processInfo
    
    override var manufacturer: String {
        return "Apple"
    }
    
    override var type: String {
        return "macOS"
    }
    
    override var model: String {
        return deviceModel()
    }
    
    override var name: String {
        return device.hostName
    }
    
    override var identifierForVendor: String? {
        return macAddress(bsd: "en0")?.lowercased()
    }
    
    override var systemName: String {
        return device.operatingSystemVersionString
    }
    
    override var systemVersion: String {
        return String(format: "%ld.%ld.%ld",
                      device.operatingSystemVersion.majorVersion,
                      device.operatingSystemVersion.minorVersion,
                      device.operatingSystemVersion.patchVersion)
    }
    
    override var screenSize: ScreenSize {
        let size = NSScreen.main?.frame.size ?? CGSize(width: 0, height: 0)
        return ScreenSize(width: Double(size.width), height: Double(size.height), density: Double(NSScreen.main?.backingScaleFactor ?? 0))
    }
    
    override var connection: ConnectionStatus {
        return connectionStatus()
    }
        
    private func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    private func macAddress(bsd: String) -> String? {
        let macAddressLength = 6
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
            for x in 0..<length {
                buffer[x] = 0
            }
            initializedCount = length
        })
        
        if sysctl(&managementInfoBase, 6, &buffer, &length, nil, 0) < 0 {
            return nil
        }
        
        let infoData = Data(bytes: buffer, count: length)
        let indexAfterMsghdr = MemoryLayout<if_msghdr>.stride + 1
        let rangeOfToken = infoData[indexAfterMsghdr...].range(of: bsdData)!
        let lower = rangeOfToken.upperBound
        let upper = lower + macAddressLength
        let macAddressData = infoData[lower..<upper]
        let addressBytes = macAddressData.map { String(format: "%02x", $0) }
        return addressBytes.joined(separator: separator)
    }
}

#endif

// MARK: - Reachability

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

#if os(macOS)
import SystemConfiguration
#endif

extension ConnectionStatus {
    init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(.connectionRequired)
        let isReachable = flags.contains(.reachable)
#if !os(macOS)
        let isCellular = flags.contains(.isWWAN)
#endif
        
        if !connectionRequired && isReachable {
#if !os(macOS)
            if isCellular {
                self = .online(.cellular)
            } else {
                self = .online(.wifi)
            }
#else
            self = .online(.wifi)
#endif
            
        } else {
            self =  .offline
        }
    }
}

internal func connectionStatus() -> ConnectionStatus {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = (withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }) else {
        return .unknown
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return .unknown
    }
    
    return ConnectionStatus(reachabilityFlags: flags)
}

#endif
