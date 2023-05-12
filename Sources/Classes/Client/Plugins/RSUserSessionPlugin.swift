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
    private var lastEventTimeStamp: Int?
    private var isNewSessionStarted: Bool = false
    
    private var previousAutoSessionTrackingStatus: Bool = false
    private var isAutomaticSessionTrackingEnabled: Bool?
    private var isSessionStopped: Bool?
    private var isManualSessionTrackingEnabled: Bool?
    
    private static var shared: RSUserSessionPlugin?
    
    required init() {}
    
    func initialSetup() {
        self.sessionTimeOut = client?.config?.sessionTimeout
        self.sessionId = RSUserDefaults.getSessionId()
        self.lastEventTimeStamp = RSUserDefaults.getLastEventTimeStamp()
        self.isSessionStopped = RSUserDefaults.getSessionStoppedStatus()
        
        if let autoSessionTrackingStatus = RSUserDefaults.getAutoSessionTrackingStatus() {
            self.previousAutoSessionTrackingStatus = autoSessionTrackingStatus
            self.isAutomaticSessionTrackingEnabled = autoSessionTrackingStatus
        }
        
        self.isManualSessionTrackingEnabled = RSUserDefaults.getManualSessionTrackingStatus()
        
        // Reset manual session
        if shouldResetManualSession() {
            startNewSession()
            configureAutoSessionTracking(true)
        }
        // Handle automatic session tracking
        else if isAutomaticSessionTrackingAllowed() {
//            if let isAutomaticSessionTrackingEnabled = self.isAutomaticSessionTrackingEnabled, !isAutomaticSessionTrackingEnabled {
//                configureAutoSessionTracking(true)
//            }
            configureAutoSessionTracking(true)
            handleAutoSessionTracking()
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
    internal func handleAutoSessionTracking() {
        guard let currentAutoSessionTrackingStatus = client?.config?.autoSessionTracking, let isAutomaticSessionTrackingEnabled = self.isAutomaticSessionTrackingEnabled
        else { return }
        
        if isAutomaticSessionTrackingEnabled && isAutomaticSessionTrackingAllowed() {
            if isSessionExpired() ||
                (!self.previousAutoSessionTrackingStatus && currentAutoSessionTrackingStatus) {
                startNewSession()
            }
        }
    }
    
    private func isSessionTrackingAllowed() -> Bool {
        if let isSessionStopped = self.isSessionStopped, isSessionStopped {
            return false
        }
        // Return true if manual session is active
        if let isAutomaticSessionTrackingEnabled = self.isAutomaticSessionTrackingEnabled, !isAutomaticSessionTrackingEnabled {
            return true
        }
        return isAutomaticSessionTrackingAllowed()
    }
    
    private func shouldResetManualSession() -> Bool {
        if let isAutomaticSessionTrackingEnabled = self.isAutomaticSessionTrackingEnabled, !isAutomaticSessionTrackingEnabled && isAutomaticSessionTrackingAllowed() {
            return true
        }
        return false
    }
    
    private func isAutomaticSessionTrackingAllowed() -> Bool {
        guard let clientConfig = client?.config,
              clientConfig.trackLifecycleEvents,
              clientConfig.autoSessionTracking
        else {
            return false
        }
        return true
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
}
    
extension RSUserSessionPlugin {
    private func stopSessionTracking(_ isSessionStopped: Bool) {
        self.isSessionStopped = isSessionStopped
        RSUserDefaults.saveSessionStoppedStatus(isSessionStopped)
    }
    
    private func configureAutoSessionTracking(_ isAutoSessionTrackingEnabled: Bool) {
        self.isAutomaticSessionTrackingEnabled = isAutoSessionTrackingEnabled
        RSUserDefaults.saveAutoSessionTrackingStatus(isAutoSessionTrackingEnabled)
        if isAutoSessionTrackingEnabled {
            stopSessionTracking(false)
            RSUserDefaults.saveManualSessionTrackingStatus(false)
            self.isManualSessionTrackingEnabled = false
        }
        // TODO: Decide to remove it or keep it
        else {
            stopSessionTracking(true)
            RSUserDefaults.saveManualSessionTrackingStatus(true)
            self.isManualSessionTrackingEnabled = true
        }
    }

    func startManualSession() {
        configureAutoSessionTracking(false)
//        RSUserDefaults.saveManualSessionTrackingStatus(true)
        startNewSession()
        stopSessionTracking(false)
    }
    
    func disableSessionTracking() {
        configureAutoSessionTracking(false)
        stopSessionTracking(true)
    }
}

extension RSClient {
    @objc
    public func startSession() {
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.startManualSession()
        }
        else {
            log(message: "SDK is not yet initialised. Hence Manual session cannot be started", logLevel: .debug)
//            let userSessionPlugin = RSUserSessionPlugin()
//            userSessionPlugin.startManualSession()
//            add(plugin: userSessionPlugin)
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
        }
//        else {
//                //            let advertisingIdPlugin = RSAdvertisingIdPlugin()
//                //            advertisingIdPlugin.advertisingId = advertisingId
//                //            add(plugin: advertisingIdPlugin)
//        }
    }
}
