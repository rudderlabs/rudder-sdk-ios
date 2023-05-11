//
//  RSUserSessionPlugin.swift
//  Pods
//
//  Created by Abhishek Pandey on 10/05/23.
//

import Foundation


class RSUserSessionPlugin: RSPlatformPlugin {
    let type = PluginType.before
    var client: RSClient? {
        didSet {
            initialSetup()
        }
    }
    
    private var sessionTimeOut: Int?
    private var sessionId: Int?
    private var isNewSessionStarted: Bool = false
    private var lastEventTimeStamp: Int?
    private var previousAutoSessionTrackingStatus: Bool = false
    var isAutomaticSessionTrackingEnabled: Bool = true
    private var isManualSessionTrackingEnabled = false
    private static var shared: RSUserSessionPlugin?
    private var trackLifeCycleEvents: Bool?
    
    required init() {}
    
    func initialSetup() {
        self.sessionTimeOut = client?.config?.sessionTimeout
        self.sessionId = RSUserDefaults.getSessionId()
        self.lastEventTimeStamp = RSUserDefaults.getLastEventTimeStamp()
        self.previousAutoSessionTrackingStatus = RSUserDefaults.getAutoSessionTrackingStatus()
        if let manualSessionTrackingStatus = RSUserDefaults.getManualSessionTrackingStatus() {
            self.isManualSessionTrackingEnabled = manualSessionTrackingStatus
        }
        if self.isManualSessionTrackingEnabled {
            disableManualSessionTracking()
            startNewSession()
        } else {
            startNewSessionIfRequired()
        }
        if let autoSessionTracking = client?.config?.autoSessionTracking {
            RSUserDefaults.saveAutoSessionTrackingStatus(autoSessionTracking)
            self.previousAutoSessionTrackingStatus = autoSessionTracking
        }
        RSUserSessionPlugin.shared = self
    }
    
    internal static func sharedInstance() -> RSUserSessionPlugin? {
        return shared
    }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        if isSessionTrackingAllowed() {
//        if isAutomaticSessionTrackingAllowed() ||
//            self.isManualSessionTrackingEnabled {
//            (!self.isAutomaticSessionTrackingEnabled && !self.isManualSessionTrackingEnabled) {
            if var context = workingMessage.context, let sessionId = self.sessionId {
                print("Abhishek sessionID: \(sessionId)")
                context[keyPath: "sessionId"] = sessionId
                if isNewSessionStarted {
                    context[keyPath: "sessionStart"] = true
                    isNewSessionStarted = false
                }
                workingMessage.context = context
                client?.updateContext(context)
            }
            let lastEventTimeStamp = RSUtils.getTimeStamp()
            RSUserDefaults.saveLastEventTimeStamp(lastEventTimeStamp)
            self.lastEventTimeStamp = lastEventTimeStamp
        }
        return workingMessage
    }
    
    // This method will be called twice: First when SDK is initialised and second when App enters into foreground
    internal func startNewSessionIfRequired() {
        guard let previousAutoSessionTrackingStatus = self.previousAutoSessionTrackingStatus,
                let currentAutoSessionTrackingStatus = client?.config?.autoSessionTracking
        else { return }
        
        if isAutomaticSessionTrackingEnabled && isAutomaticSessionTrackingAllowed() {
            if isSessionExpired() ||
                (!previousAutoSessionTrackingStatus && currentAutoSessionTrackingStatus) {
                startNewSession()
            }
        }
    }
    
//    private func isSessionTrackingAllowed() -> Bool {
//        return self.isManualSessionTrackingEnabled || self.isAutomaticSessionTrackingEnabled && isAutomaticSessionTrackingAllowed()
//    }

    private func isSessionTrackingAllowed() -> Bool {
        if !self.isAutomaticSessionTrackingEnabled && !self.isManualSessionTrackingEnabled {
            return false
        }
        if self.isManualSessionTrackingEnabled {
            return true
        }
        return isAutomaticSessionTrackingAllowed()
    }
    
    private func isAutomaticSessionTrackingAllowed() -> Bool {
//        if !self.isAutomaticSessionTrackingEnabled && !self.isManualSessionTrackingEnabled {
//            return false
//        }
        if let isLifecycleAllowed = client?.config?.trackLifecycleEvents,
           let isSessionTrackingAllowed = client?.config?.autoSessionTracking,
           isLifecycleAllowed && isSessionTrackingAllowed {
            return true
        }
        return false
    }
    
    // This method should be called only when session tracking is allowed
    private func isSessionExpired() -> Bool {
        guard let lastEventTimeStamp = self.lastEventTimeStamp, let sessionTimeOut = self.sessionTimeOut else {
            // SDK is initialised for the first time
            return true
        }
        
        let timeDifference: TimeInterval = TimeInterval(abs(RSUtils.getTimeStamp() - lastEventTimeStamp))
        print ("Abhishek \(timeDifference)")
        return timeDifference >= Double(sessionTimeOut / 1000)
    }
    
    func startNewSession() {
        startNewSession(nil)
    }
    
    func startNewSession(_ newSessionId: Int?) {
        print("Abhishek: New session starts")
        var sessionId = RSUtils.getTimeStamp()
        if let inputSessionId = newSessionId {
            sessionId = inputSessionId
        }
        client?.log(message: "New session is started", logLevel: .verbose)
        isNewSessionStarted = true
        RSUserDefaults.saveSessionId(sessionId)
        self.sessionId = sessionId
    }
    
    // Disable manual session tracking only when automatic session tracking is enabled while SDK initialisation
    func disableManualSessionTracking() {
        RSUserDefaults.saveManualSessionTrackingStatus(false)
        self.isManualSessionTrackingEnabled = false
    }
    
    func disableAutomaticSessionTracking() {
        self.isAutomaticSessionTrackingEnabled = false
        if !isAutomaticSessionTrackingAllowed() {
            RSUserDefaults.saveAutoSessionTrackingStatus(false)
        }
        RSUserDefaults.saveManualSessionTrackingStatus(true)
        self.isManualSessionTrackingEnabled = true
    }
    
    func disableSessionTracking() {
        disableAutomaticSessionTracking()
        disableManualSessionTracking()
    }
}

extension RSClient {
    @objc
    public func startSession() {
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.disableAutomaticSessionTracking()
            userSessionPlugin.startNewSession()
//            userSessionPlugin.initialSetup()
        } else {
//            let advertisingIdPlugin = RSAdvertisingIdPlugin()
//            advertisingIdPlugin.advertisingId = advertisingId
//            add(plugin: advertisingIdPlugin)
        }
    }
    
    @objc
    public func startSession(_ sessionId: Int) {
        guard sessionId != nil else {
            log(message: "sessionId can not be empty", logLevel: .warning)
            return
        }
        
        if String(sessionId).count < 10 {
            log(message: "RSClient: startSession: Length of the sessionId should be atleast 10: (sessionId)", logLevel: .error)
            return
        }
    }
    
    @objc
    public func endSession() {
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.disableSessionTracking()
                //            userSessionPlugin.initialSetup()
        } else {
                //            let advertisingIdPlugin = RSAdvertisingIdPlugin()
                //            advertisingIdPlugin.advertisingId = advertisingId
                //            add(plugin: advertisingIdPlugin)
        }
    }
}
