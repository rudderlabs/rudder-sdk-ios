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
    
    private var userDefaults: RSUserDefaults?
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
        guard let client = self.client else { return }
        sessionTimeOut = client.config?.sessionTimeout
        userDefaults = client.userDefaults
        sessionId = userDefaults?.read(.sessionId)
        lastEventTimeStamp = userDefaults?.read(.lastEventTimeStamp)
        
        if isAutomaticSessionTrackingAllowed {
            if let previousAutomaticSessionTrackingStatus: Bool = userDefaults?.read(.automaticSessionTrackingStatus),
               (isSessionExpired() || !previousAutomaticSessionTrackingStatus) {
                startNewSession(nil)
                userDefaults?.write(.automaticSessionTrackingStatus, value: true)
                userDefaults?.write(.manualSessionTrackingStatus, value: false)
                userDefaults?.write(.sessionStoppedStatus, value: false)
            }
        } else {
            userDefaults?.write(.automaticSessionTrackingStatus, value: false)
        }
        refreshSesionParams()
    }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        if isSessionTrackingAllowed {
            if let sessionId = self.sessionId {
                workingMessage.sessionId = sessionId
                if isNewSessionStarted {
                    workingMessage.sessionStart = true
                    isNewSessionStarted = false
                }
            }
            let currentEventTimeStamp = RSUtils.getTimeStamp()
            userDefaults?.write(.lastEventTimeStamp, value: currentEventTimeStamp)
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
        let sessionId: Int = newSessionId ?? RSUtils.getTimeStamp()
        Logger.log(message: "New session is started", logLevel: .verbose)
        isNewSessionStarted = true
        userDefaults?.write(.sessionId, value: sessionId)
        self.sessionId = sessionId
    }
    
    private func refreshSesionParams() {
        self.isAutomaticSessionTrackingStatus = userDefaults?.read(.automaticSessionTrackingStatus) ?? false
        self.isManualSessionTrackingStatus = userDefaults?.read(.manualSessionTrackingStatus) ?? false
        self.isSessionStoppedStatus = userDefaults?.read(.sessionStoppedStatus) ?? false
        self.lastEventTimeStamp = userDefaults?.read(.lastEventTimeStamp)
    }
}
    
extension RSUserSessionPlugin {
    func startManualSession(_ sessionId: Int?) {
        userDefaults?.write(.automaticSessionTrackingStatus, value: false)
        userDefaults?.write(.manualSessionTrackingStatus, value: true)
        userDefaults?.write(.sessionStoppedStatus, value: false)
        userDefaults?.remove(.lastEventTimeStamp)
        
        refreshSesionParams()
        
        startNewSession(sessionId)
    }
    
    func endSession() {
        userDefaults?.write(.automaticSessionTrackingStatus, value: false)
        userDefaults?.write(.manualSessionTrackingStatus, value: false)
        userDefaults?.write(.sessionStoppedStatus, value: true)
        userDefaults?.remove(.lastEventTimeStamp)
    
        refreshSesionParams()
    }
    
    func reset() {
        if isSessionTrackingAllowed {
            userDefaults?.remove(.lastEventTimeStamp)
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
            Logger.log(message: "SDK is not yet initialised. Hence manual session cannot be started", logLevel: .debug)
        }
    }
    
    @objc
    public func startSession(_ sessionId: Int) {
        guard String(sessionId).count >= 10 else {
            Logger.log(message: "RSClient: startSession: Length of the sessionId should be at least 10: \(sessionId)", logLevel: .error)
            return
        }
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.startManualSession(sessionId)
        } else {
            Logger.log(message: "SDK is not yet initialised. Hence manual session cannot be started", logLevel: .debug)
        }
    }
    
    @objc
    public func endSession() {
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self) {
            userSessionPlugin.endSession()
        }
    }
}
