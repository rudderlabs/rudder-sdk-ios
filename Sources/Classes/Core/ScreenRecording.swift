//
//  ScreenViews.swift
//  Rudder
//
//  Created by Pallab Maiti on 29/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

struct ScreenRecordingMessage {
    let screenName: String
    let properties: ScreenProperties?
}

class ScreenRecording {
    var capture: ((ScreenRecordingMessage) -> Void) = { _  in }
    
    init() {
        rudderSwizzleView()
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIKit

extension ScreenRecording {
    func rudderSwizzleView() {
        UIViewController.rudderSwizzleView()
        UIViewController.capture = { [weak self] ScreenRecordingMessage in
            guard let self = self else { return }
            self.capture(ScreenRecordingMessage)
        }
    }
}

extension UIViewController {
    static var capture: ((ScreenRecordingMessage) -> Void) = { _  in }
    
    static func rudderSwizzleView() {
        let originalSelector = #selector(viewDidAppear(_:))
        let swizzledSelector = #selector(rsViewDidAppear(_:))
        
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
    func rsViewDidAppear(_ animated: Bool) {
        var name = NSStringFromClass(type(of: self))
        name = name.replacingOccurrences(of: "ViewController", with: "")
        Self.capture(ScreenRecordingMessage(screenName: name, properties: ["automatic": true, "name": name]))
        rsViewDidAppear(animated)
    }
}

#elseif os(watchOS)

import WatchKit

extension ScreenRecording {
    func rudderSwizzleView() {
        WKInterfaceController.rudderSwizzleView()
        WKInterfaceController.capture = { [weak self] ScreenRecordingMessage in
            guard let self = self else { return }
            self.capture(ScreenRecordingMessage)
        }
    }
}

extension WKInterfaceController {
    static var capture: ((ScreenRecordingMessage) -> Void) = { _  in }
    
    static func rudderSwizzleView() {
        let originalSelector = #selector(didAppear)
        let swizzledSelector = #selector(rsDidAppear)
        
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
    func rsDidAppear() {
        var name = NSStringFromClass(Swift.type(of: self))
        name = name.replacingOccurrences(of: "InterfaceController", with: "")
        Self.capture(ScreenRecordingMessage(screenName: name, properties: ["automatic": true, "name": name]))
        rsDidAppear()
    }
}

#elseif os(macOS)
import Cocoa

extension ScreenRecording {
    func rudderSwizzleView() {
        NSViewController.rudderSwizzleView()
        NSViewController.capture = { [weak self] ScreenRecordingMessage in
            guard let self = self else { return }
            self.capture(ScreenRecordingMessage)
        }
    }
}

extension NSViewController {
    static var capture: ((ScreenRecordingMessage) -> Void) = { _  in }
    
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
        Self.capture(ScreenRecordingMessage(screenName: name, properties: ["automatic": true, "name": name]))
        rsViewDidAppear()
    }
}

#endif
