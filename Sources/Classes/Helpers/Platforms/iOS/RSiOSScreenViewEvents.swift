//
//  RSiOSScreenViewEvents.swift
//  RudderStack
//
//  Created by Pallab Maiti on 03/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

class RSiOSScreenViewEvents: RSPlatformPlugin {
    let type = PluginType.before
    var client: RSClient? {
        didSet {
            rudderSwizzleView()
        }
    }
    
    func rudderSwizzleView() {
        UIViewController.client = client
        UIViewController.rudderSwizzleView()
    }
}

extension UIViewController {
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
        let screenMessage = ScreenMessage(title: name, properties: ["automatic": true, "name": name]).applyRawEventData(userInfo: UIViewController.client?.userInfo)
        UIViewController.client?.process(message: screenMessage)
        rsViewDidAppear(animated)
    }
}

extension UIViewController {
    private struct AssociatedKey {
        static var client: RSClient?
    }
    
    static var client: RSClient? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.client) as? RSClient
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKey.client, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

#endif
