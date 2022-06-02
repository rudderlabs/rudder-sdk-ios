//
//  RSLifeCycle.swift
//  RudderStack
//
//  Created by Pallab Maiti on 03/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#if os(macOS)
import Cocoa

public protocol RSmacOSLifecycle {
    func applicationDidResignActive()
    func application(didFinishLaunchingWithOptions launchOptions: [String: Any]?)
    func applicationWillBecomeActive()
    func applicationDidBecomeActive()
    func applicationWillHide()
    func applicationDidHide()
    func applicationDidUnhide()
    func applicationDidUpdate()
    func applicationWillFinishLaunching()
    func applicationWillResignActive()
    func applicationWillUnhide()
    func applicationWillUpdate()
    func applicationWillTerminate()
    func applicationDidChangeScreenParameters()
}

public extension RSmacOSLifecycle {
    func applicationDidResignActive() { }
    func application(didFinishLaunchingWithOptions launchOptions: [String: Any]?) { }
    func applicationWillBecomeActive() { }
    func applicationDidBecomeActive() { }
    func applicationWillHide() { }
    func applicationDidHide() { }
    func applicationDidUnhide() { }
    func applicationDidUpdate() { }
    func applicationWillFinishLaunching() { }
    func applicationWillResignActive() { }
    func applicationWillUnhide() { }
    func applicationWillUpdate() { }
    func applicationWillTerminate() { }
    func applicationDidChangeScreenParameters() { }
}
#endif

#if os(watchOS)

import Foundation
import WatchKit

public protocol RSwatchOSLifecycle {
    func applicationDidFinishLaunching(watchExtension: WKExtension?)
    func applicationWillEnterForeground(watchExtension: WKExtension?)
    func applicationDidEnterBackground(watchExtension: WKExtension?)
    func applicationDidBecomeActive(watchExtension: WKExtension?)
    func applicationWillResignActive(watchExtension: WKExtension?)
}

public extension RSwatchOSLifecycle {
    func applicationDidFinishLaunching(watchExtension: WKExtension?) { }
    func applicationWillEnterForeground(watchExtension: WKExtension?) { }
    func applicationDidEnterBackground(watchExtension: WKExtension?) { }
    func applicationDidBecomeActive(watchExtension: WKExtension?) { }
    func applicationWillResignActive(watchExtension: WKExtension?) { }
}
#endif

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Foundation
import UIKit

public protocol RSiOSLifecycle {
    func applicationDidEnterBackground(application: UIApplication?)
    func applicationWillEnterForeground(application: UIApplication?)
    func application(_ application: UIApplication?, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func application(_ app: UIApplication?, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any])
    func applicationDidBecomeActive(application: UIApplication?)
    func applicationWillResignActive(application: UIApplication?)
    func applicationDidReceiveMemoryWarning(application: UIApplication?)
    func applicationWillTerminate(application: UIApplication?)
    func applicationSignificantTimeChange(application: UIApplication?)
    func applicationBackgroundRefreshDidChange(application: UIApplication?, refreshStatus: UIBackgroundRefreshStatus)
}

public extension RSiOSLifecycle {
    func applicationDidEnterBackground(application: UIApplication?) { }
    func applicationWillEnterForeground(application: UIApplication?) { }
    func application(_ application: UIApplication?, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) { }
    func application(_ app: UIApplication?, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) { }
    func applicationDidBecomeActive(application: UIApplication?) { }
    func applicationWillResignActive(application: UIApplication?) { }
    func applicationDidReceiveMemoryWarning(application: UIApplication?) { }
    func applicationWillTerminate(application: UIApplication?) { }
    func applicationSignificantTimeChange(application: UIApplication?) { }
    func applicationBackgroundRefreshDidChange(application: UIApplication?, refreshStatus: UIBackgroundRefreshStatus) { }
}
#endif
