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
    private var isNewSessionStarted = false
    
    var sessionId: Int? {
        userDefaults?.read(.sessionId)
    }
    
    private var lastEventTimeStamp: Int? {
        userDefaults?.read(.lastEventTimeStamp)
    }
    
    private var automaticSessionTrackingStatus: Bool {
        userDefaults?.read(.automaticSessionTrackingStatus) ?? false
    }
    
    private var sessionStoppedStatus: Bool {
        userDefaults?.read(.sessionStoppedStatus) ?? false
    }
    
    private var manualSessionTrackingStatus: Bool {
        userDefaults?.read(.manualSessionTrackingStatus) ?? false
    }
    
    private var isSessionTrackingAllowed: Bool {
        if !sessionStoppedStatus && (manualSessionTrackingStatus || isAutomaticSessionTrackingAllowed) {
            return true
        }
        return false
    }
    
    private var isAutomaticSessionTrackingAllowed: Bool {
        guard let config = client?.config, config.trackLifecycleEvents, config.automaticSessionTracking else {
            return false
        }
        return true
    }
        
    required init() {}
    
    func initialSetup() {
        guard let client = self.client else { return }
        sessionTimeOut = client.config?.sessionTimeout
        userDefaults = client.userDefaults
        
        if isAutomaticSessionTrackingAllowed {
            if isSessionExpired() || !automaticSessionTrackingStatus {
                startNewSession()
                userDefaults?.write(.automaticSessionTrackingStatus, value: true)
                userDefaults?.write(.manualSessionTrackingStatus, value: false)
                userDefaults?.write(.sessionStoppedStatus, value: false)
            }
        } else {
            userDefaults?.write(.automaticSessionTrackingStatus, value: false)
        }
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
    
    func startNewSession(_ sessionId: Int? = nil) {
        isNewSessionStarted = true
        userDefaults?.write(.sessionId, value: sessionId ?? RSUtils.getTimeStamp())
        Logger.log(message: "New session is started", logLevel: .verbose)
    }
}
    
extension RSUserSessionPlugin {
    func startManualSession(_ sessionId: Int? = nil) {
        userDefaults?.write(.automaticSessionTrackingStatus, value: false)
        userDefaults?.write(.manualSessionTrackingStatus, value: true)
        userDefaults?.write(.sessionStoppedStatus, value: false)
        userDefaults?.remove(.lastEventTimeStamp)
        
        startNewSession(sessionId)
    }
    
    func endSession() {
        userDefaults?.write(.automaticSessionTrackingStatus, value: false)
        userDefaults?.write(.manualSessionTrackingStatus, value: false)
        userDefaults?.write(.sessionStoppedStatus, value: true)
        userDefaults?.remove(.lastEventTimeStamp)
    }
    
    func reset() {
        if isSessionTrackingAllowed {
            if automaticSessionTrackingStatus {
                userDefaults?.write(.lastEventTimeStamp, value: RSUtils.getTimeStamp())
            }
            startNewSession()
        }
    }
    
    func refreshSessionIfNeeded() {
        if isSessionTrackingAllowed, automaticSessionTrackingStatus, isSessionExpired() {
            startNewSession()
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
            userSessionPlugin.startManualSession()
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
