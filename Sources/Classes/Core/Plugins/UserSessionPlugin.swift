//
//  RSUserSessionPlugin.swift
//  Pods
//
//  Created by Abhishek Pandey on 10/05/23.
//

import Foundation

class UserSessionPlugin: Plugin {
    var sourceConfig: SourceConfig?
    
    var type: PluginType = .default
    
    var client: RSClient? {
        didSet {
            setUp()
        }
    }
    
    private var userDefaults: UserDefaultsWorkerType?
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
    
    func setUp() {
        guard let client = self.client else { return }
        sessionTimeOut = client.config.sessionTimeout
        userDefaults = client.controller.userDefaults
        
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
    
    func process<T>(message: T?) -> T? where T: Message {
        guard var workingMessage = message else { return message }
        if isSessionTrackingAllowed {
            if let sessionId = self.sessionId {
                workingMessage.sessionId = sessionId
                if isNewSessionStarted {
                    workingMessage.sessionStart = true
                    isNewSessionStarted = false
                }
            }
            let currentEventTimeStamp = Utility.getTimeStamp()
            userDefaults?.write(.lastEventTimeStamp, value: currentEventTimeStamp)
        }
        return workingMessage
    }
    
    // This method should be called only when session tracking is allowed
    private func isSessionExpired() -> Bool {
        guard let lastEventTimeStamp = self.lastEventTimeStamp, let sessionTimeOut = self.sessionTimeOut else {
            return true
        }
        
        let timeDifference: TimeInterval = TimeInterval(abs(Utility.getTimeStamp() - lastEventTimeStamp))
        return timeDifference >= Double(sessionTimeOut / 1000)
    }
    
    func startNewSession(_ sessionId: Int? = nil) {
        isNewSessionStarted = true
        userDefaults?.write(.sessionId, value: sessionId ?? Utility.getTimeStamp())
        client?.logDebug(LogMessages.newSession.description)
    }
}
    
extension UserSessionPlugin {
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
                userDefaults?.remove(.lastEventTimeStamp)
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

extension Controller {
    internal func refreshSessionIfNeeded() {
        if let userSessionPlugin = getPlugin(type: UserSessionPlugin.self) {
            userSessionPlugin.refreshSessionIfNeeded()
        }
    }
}

extension RSClient {
    public func startSession() {
        if let userSessionPlugin = getPlugin(type: UserSessionPlugin.self) {
            userSessionPlugin.startManualSession()
        } else {
            logDebug(LogMessages.sessionCanNotStart.description)
        }
    }
    
    public func startSession(_ sessionId: Int) {
        guard String(sessionId).count >= 10 else {
            logError(LogMessages.sessionIdLengthInvalid(sessionId).description)
            return
        }
        if let userSessionPlugin = getPlugin(type: UserSessionPlugin.self) {
            userSessionPlugin.startManualSession(sessionId)
        } else {
            logDebug(LogMessages.sessionCanNotStart.description)
        }
    }
    
    public func endSession() {
        if let userSessionPlugin = getPlugin(type: UserSessionPlugin.self) {
            userSessionPlugin.endSession()
        }
    }
}
