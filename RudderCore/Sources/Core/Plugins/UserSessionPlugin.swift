//
//  RSUserSessionPlugin.swift
//  Pods
//
//  Created by Abhishek Pandey on 10/05/23.
//

import Foundation

struct UserSessionPresets {
    let userDefaultsWorker: UserDefaultsWorkerProtocol
    let configuration: Configuration

    var isNewSessionStarted = false
    
    var sessionId: Int? {
        get {
            userDefaultsWorker.read(.sessionId)
        }
        set {
            if newValue == nil {
                userDefaultsWorker.remove(.sessionId)
            } else {
                userDefaultsWorker.write(.sessionId, value: newValue)
            }
        }
    }
    
    var lastEventTimeStamp: Int? {
        get {
            userDefaultsWorker.read(.lastEventTimeStamp)
        }
        set {
            if newValue == nil {
                userDefaultsWorker.remove(.lastEventTimeStamp)
            } else {
                userDefaultsWorker.write(.lastEventTimeStamp, value: newValue)
            }
        }
    }
    
    var automaticSessionTrackingStatus: Bool {
        get {
            userDefaultsWorker.read(.automaticSessionTrackingStatus) ?? false
        }
        set {
            userDefaultsWorker.write(.automaticSessionTrackingStatus, value: newValue)
        }
    }
    
    var sessionStoppedStatus: Bool {
        get {
            userDefaultsWorker.read(.sessionStoppedStatus) ?? false
        }
        set {
            userDefaultsWorker.write(.sessionStoppedStatus, value: newValue)
        }
    }
    
    var manualSessionTrackingStatus: Bool {
        get {
            userDefaultsWorker.read(.manualSessionTrackingStatus) ?? false
        }
        set {
            userDefaultsWorker.write(.manualSessionTrackingStatus, value: newValue)
        }
    }
    
    var isSessionTrackingAllowed: Bool {
        if !sessionStoppedStatus && (manualSessionTrackingStatus || isAutomaticSessionTrackingAllowed) {
            return true
        }
        return false
    }
    
    var isAutomaticSessionTrackingAllowed: Bool {
        return configuration.trackLifecycleEvents && configuration.automaticSessionTracking
    }
    
    var isSessionExpired: Bool {
        guard let lastEventTimeStamp = self.lastEventTimeStamp else {
            return true
        }
        
        let timeDifference: TimeInterval = TimeInterval(abs(.getTimeStamp() - lastEventTimeStamp))
        return timeDifference >= Double(configuration.sessionTimeOut / 1000)
    }
    
    init(userDefaultsWorker: UserDefaultsWorkerProtocol, configuration: Configuration) {
        self.userDefaultsWorker = userDefaultsWorker
        self.configuration = configuration
    }
}

class UserSessionPlugin: Plugin {
    var sourceConfig: SourceConfig?
    
    var type: PluginType = .default
    
    var client: RudderProtocol? {
        didSet {
            setUp()
        }
    }
        
    private var userSessionPresets: UserSessionPresets?
    var sessionId: Int? {
        userSessionPresets?.sessionId
    }
        
    func setUp() {
        guard let client = self.client else { return }
        userSessionPresets = UserSessionPresets(userDefaultsWorker: client.userDefaultsWorker, configuration: client.configuration)
        if userSessionPresets?.isAutomaticSessionTrackingAllowed == true &&
            (userSessionPresets?.isSessionExpired == true ||
             userSessionPresets?.automaticSessionTrackingStatus == false
            ) {
            startNewSession()
            userSessionPresets?.automaticSessionTrackingStatus = true
            userSessionPresets?.manualSessionTrackingStatus = false
            userSessionPresets?.sessionStoppedStatus = false
        } else {
            userSessionPresets?.automaticSessionTrackingStatus = false
        }
    }
    
    func process<T>(message: T?) -> T? where T: Message {
        guard var workingMessage = message else { return message }
        if userSessionPresets?.isSessionTrackingAllowed == true {
            if let sessionId = userSessionPresets?.sessionId {
                workingMessage.sessionId = sessionId
                if userSessionPresets?.isNewSessionStarted == true {
                    workingMessage.sessionStart = true
                    userSessionPresets?.isNewSessionStarted = false
                }
            }
            userSessionPresets?.lastEventTimeStamp = .getTimeStamp()
        }
        return workingMessage
    }
}
    
extension UserSessionPlugin {
    private func startNewSession(_ sessionId: Int? = nil) {
        userSessionPresets?.isNewSessionStarted = true
        userSessionPresets?.sessionId = sessionId ?? .getTimeStamp()
        client?.logger.logDebug(.newSession)
    }
    
    func startSession(_ sessionId: Int? = nil) {
        userSessionPresets?.automaticSessionTrackingStatus = false
        userSessionPresets?.manualSessionTrackingStatus = true
        userSessionPresets?.sessionStoppedStatus = false
        userSessionPresets?.lastEventTimeStamp = nil
        
        startNewSession(sessionId)
    }
    
    func endSession() {
        userSessionPresets?.sessionId = nil
        userSessionPresets?.automaticSessionTrackingStatus = false
        userSessionPresets?.manualSessionTrackingStatus = false
        userSessionPresets?.sessionStoppedStatus = true
        userSessionPresets?.lastEventTimeStamp = nil
    }
    
    func reset() {
        if userSessionPresets?.isSessionTrackingAllowed == true {
            if userSessionPresets?.automaticSessionTrackingStatus == true {
                userSessionPresets?.lastEventTimeStamp = nil
            }
            startNewSession()
        }
    }
    
    func refreshSessionIfNeeded() {
        if let userSessionPresets = userSessionPresets,
           userSessionPresets.isSessionTrackingAllowed,
           userSessionPresets.automaticSessionTrackingStatus,
           userSessionPresets.isSessionExpired {
            startNewSession()
        }
    }
}

extension RudderCore {
    internal func refreshSessionIfNeeded() {
        if let userSessionPlugin = getPlugin(type: UserSessionPlugin.self) {
            userSessionPlugin.refreshSessionIfNeeded()
        }
    }
}

extension RSClient {
    public func startSession() {
        if let userSessionPlugin = getPlugin(type: UserSessionPlugin.self) {
            userSessionPlugin.startSession()
        } else {
            logger.logDebug(.sessionCanNotStart)
        }
    }
    
    public func startSession(_ sessionId: Int) {
        guard String(sessionId).count >= 10 else {
            logger.logError(.sessionIdLengthInvalid(sessionId))
            return
        }
        if let userSessionPlugin = getPlugin(type: UserSessionPlugin.self) {
            userSessionPlugin.startSession(sessionId)
        } else {
            logger.logDebug(.sessionCanNotStart)
        }
    }
    
    public func endSession() {
        if let userSessionPlugin = getPlugin(type: UserSessionPlugin.self) {
            userSessionPlugin.endSession()
        }
    }
}
