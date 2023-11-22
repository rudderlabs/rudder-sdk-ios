//
//  RSmacOSScreenViewEvents.swift
//  RudderStack
//
//  Created by Pallab Maiti on 03/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

#if os(macOS)

import Cocoa

class RSmacOSScreenViewEvents: RSPlatformPlugin {
    let type = PluginType.before
    var client: RSClient? {
        didSet {
            rudderSwizzleView()
        }
    }
    
    func rudderSwizzleView() {
        NSViewController.client = client
        NSViewController.rudderSwizzleView()
    }
}

extension NSViewController {
    static var client: RSClient?
    
    static func rudderSwizzleView() {
        let originalSelector = #selector(self.viewDidAppear)
        let swizzledSelector = #selector(self.rsViewDidAppear)
        
        if let originalMethod = class_getInstanceMethod(self, originalSelector), let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) {
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
    
    @objc
    func rsViewDidAppear() {
        var name = NSStringFromClass(type(of: self))
        name = name.replacingOccurrences(of: "ViewController", with: "")
        let screenMessage = ScreenMessage(title: name, properties: ["automatic": true, "name": name]).applyRawEventData(userInfo: NSViewController.client?.userInfo)
        NSViewController.client?.process(message: screenMessage)
        rsViewDidAppear()
    }
}

#endif
