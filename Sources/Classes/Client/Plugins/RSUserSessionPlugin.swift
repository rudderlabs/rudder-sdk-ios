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
    
    private var isAutomaticSessionTrackingEnabled: Bool?
    private var isSessionStopped: Bool?
    private var isManualSessionTrackingEnabled: Bool?
    
    private static var shared: RSUserSessionPlugin?
    
    required init() {}
    
    func initialSetup() {
        self.sessionTimeOut = client?.config?.sessionTimeout
        self.sessionId = RSUserDefaults.getSessionId()
        self.lastEventTimeStamp = RSUserDefaults.getLastEventTimeStamp()
        
        if isAutomaticSessionTrackingAllowed() {
            if let previousAutomaticSessionTrackingStatus = RSUserDefaults.getAutomaticSessionTrackingStatus(),
                isSessionExpired() ||
                !previousAutomaticSessionTrackingStatus {
                startNewSession()
                RSUserDefaults.saveAutomaticSessionTrackingStatus(true)
                RSUserDefaults.saveManualSessionTrackingStatus(false)
                RSUserDefaults.saveSessionStoppedStatus(false)
            }
        } else {
            RSUserDefaults.saveAutomaticSessionTrackingStatus(false)
        }
        refreshSesionParams()
        RSUserSessionPlugin.shared = self
    }
    
    internal static func sharedInstance() -> RSUserSessionPlugin? {
        return shared
    }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        if isSessionTrackingAllowed() {
            if var context = workingMessage.context,
                let sessionId = self.sessionId {
                print("Abhishek2 sessionID: \(sessionId)")
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
    
    internal func refreshSessionWhenAppEntersForeground() {
        if isSessionTrackingAllowed(),
            let automaticSessionTrackingEnabled = self.isAutomaticSessionTrackingEnabled,
            automaticSessionTrackingEnabled &&
            isSessionExpired() {
            startNewSession()
        }
    }
    
    private func isSessionTrackingAllowed() -> Bool {
        if !isEndSessionTrackingActive() &&
            (isManualSessionTrackingAllowed() || isAutomaticSessionTrackingAllowed()) {
            return true
        }
        return false
    }
    
    private func isAutomaticSessionTrackingAllowed() -> Bool {
        guard let clientConfig = client?.config,
              clientConfig.trackLifecycleEvents,
              clientConfig.automaticSessionTracking
        else {
            return false
        }
        return true
    }
    
    private func isManualSessionTrackingAllowed() -> Bool {
        return self.isManualSessionTrackingEnabled == true
    }
    
    private func isEndSessionTrackingActive() -> Bool {
        return self.isSessionStopped == true
    }
    
    // This method should be called only when session tracking is allowed
    private func isSessionExpired() -> Bool {
        guard let lastEventTimeStamp = self.lastEventTimeStamp,
                let sessionTimeOut = self.sessionTimeOut else {
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
        RSUserDefaults.saveSessionId(nil)
        self.sessionId = sessionId
    }
    
    private func refreshSesionParams() {
        self.isAutomaticSessionTrackingEnabled = RSUserDefaults.getAutomaticSessionTrackingStatus()
        self.isManualSessionTrackingEnabled = RSUserDefaults.getManualSessionTrackingStatus()
        self.isSessionStopped = RSUserDefaults.getSessionStoppedStatus()
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
        if isSessionTrackingAllowed() {
            print("Abhishek RESET is called")
            RSUserDefaults.saveLastEventTimeStamp(RSUtils.getTimeStamp())
            startNewSession()
        }
    }
}

extension RSClient {
    @objc
    public func startSession() {
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.startManualSession(nil)
        }
        else {
            log(message: "SDK is not yet initialised. Hence manual session cannot be started", logLevel: .debug)
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
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.startManualSession(sessionId)
        }
        else {
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
