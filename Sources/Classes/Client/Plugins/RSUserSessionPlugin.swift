//
//  RSUserSessionPlugin.swift
//  Pods
//
//  Created by Abhishek Pandey on 10/05/23.
//

import Foundation

class RSUserSessionPlugin: RSPlatformPlugin, RSEventPlugin {
    let type = PluginType.before
    var client: RSClient? {
        didSet {
            initialSetup()
        }
    }
    
    private var sessionTimeOut: Int?
    private var isNewSessionStarted: Bool = false
    
    private var sessionId: Int?
    private var lastEventTimeStamp: Int?
    
    private var isAutomaticSessionTrackingStatus = false
    private var isSessionStoppedStatus = false
    private var isManualSessionTrackingStatus = false
    
    private var isSessionTrackingAllowed: Bool {
        if !isSessionStoppedStatus && (isManualSessionTrackingStatus || isAutomaticSessionTrackingAllowed) {
            return true
        }
        return false
    }
    
    private var isAutomaticSessionTrackingAllowed: Bool {
        guard let clientConfig = client?.config, clientConfig.trackLifecycleEvents, clientConfig.automaticSessionTracking else {
            return false
        }
        return true
    }
        
    required init() {}
    
    func initialSetup() {
        self.sessionTimeOut = client?.config?.sessionTimeout
        self.sessionId = RSUserDefaults.getSessionId()
        self.lastEventTimeStamp = RSUserDefaults.getLastEventTimeStamp()
        
        if isAutomaticSessionTrackingAllowed {
            if let previousAutomaticSessionTrackingStatus = RSUserDefaults.getAutomaticSessionTrackingStatus(),
                (isSessionExpired() || !previousAutomaticSessionTrackingStatus) {
                startNewSession(nil)
                RSUserDefaults.saveAutomaticSessionTrackingStatus(true)
                RSUserDefaults.saveManualSessionTrackingStatus(false)
                RSUserDefaults.saveSessionStoppedStatus(false)
            }
        } else {
            RSUserDefaults.saveAutomaticSessionTrackingStatus(false)
        }
        refreshSesionParams()
    }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        if isSessionTrackingAllowed {
            if var context = workingMessage.context,
                let sessionId = self.sessionId {
                context[keyPath: "sessionId"] = sessionId
                if isNewSessionStarted {
                    context[keyPath: "sessionStart"] = true
                    isNewSessionStarted = false
                }
                workingMessage.context = context
                client?.updateContext(context)
            }
            let currentEventTimeStamp = RSUtils.getTimeStamp()
            RSUserDefaults.saveLastEventTimeStamp(currentEventTimeStamp)
            self.lastEventTimeStamp = currentEventTimeStamp
        }
        return workingMessage
    }
    
    // This method should be called only when session tracking is allowed
    private func isSessionExpired() -> Bool {
        guard let lastEventTimeStamp = self.lastEventTimeStamp, let sessionTimeOut = self.sessionTimeOut else {
            return true
        }
        
        let timeDifference: TimeInterval = TimeInterval(abs(RSUtils.getTimeStamp() - lastEventTimeStamp))
        return timeDifference >= Double(sessionTimeOut / 1000)
    }
    
    func startNewSession(_ newSessionId: Int?) {
        var sessionId: Int = newSessionId ?? RSUtils.getTimeStamp()
        client?.log(message: "New session is started", logLevel: .verbose)
        isNewSessionStarted = true
        RSUserDefaults.saveSessionId(sessionId)
        self.sessionId = sessionId
    }
    
    private func refreshSesionParams() {
        self.isAutomaticSessionTrackingStatus = RSUserDefaults.getAutomaticSessionTrackingStatus() ?? false
        self.isManualSessionTrackingStatus = RSUserDefaults.getManualSessionTrackingStatus() ?? false
        self.isSessionStoppedStatus = RSUserDefaults.getSessionStoppedStatus() ?? false
    }
}
    
extension RSUserSessionPlugin {
    func startManualSession(_ sessionId: Int?) {
        RSUserDefaults.saveAutomaticSessionTrackingStatus(false)
        RSUserDefaults.saveManualSessionTrackingStatus(true)
        RSUserDefaults.saveSessionStoppedStatus(false)
        
        refreshSesionParams()
        
        startNewSession(sessionId)
    }
    
    func endSession() {
        RSUserDefaults.saveAutomaticSessionTrackingStatus(false)
        RSUserDefaults.saveManualSessionTrackingStatus(false)
        RSUserDefaults.saveSessionStoppedStatus(true)
    
        refreshSesionParams()
    }
    
    func reset() {
        if isSessionTrackingAllowed {
            RSUserDefaults.saveLastEventTimeStamp(nil)
            startNewSession(nil)
        }
    }
    
    func refreshSessionIfNeeded() {
        if isSessionTrackingAllowed, isAutomaticSessionTrackingStatus, isSessionExpired() {
            startNewSession(nil)
        }
    }
}

extension RSClient {
    internal func refreshSessionIfNeeded() {
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.refreshSessionIfNeeded()
        }
    }
}

extension RSClient {
    @objc
    public func startSession() {
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.startManualSession(nil)
        } else {
            log(message: "SDK is not yet initialised. Hence manual session cannot be started", logLevel: .debug)
        }
    }
    
    @objc
    public func startSession(_ sessionId: Int) {
        guard String(sessionId).count >= 10 else {
            log(message: "RSClient: startSession: Length of the sessionId should be at least 10: \(sessionId)", logLevel: .error)
            return
        }
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.startManualSession(sessionId)
        } else {
            log(message: "SDK is not yet initialised. Hence manual session cannot be started", logLevel: .debug)
        }
    }
    
    @objc
    public func endSession() {
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.endSession()
        }
    }
}
