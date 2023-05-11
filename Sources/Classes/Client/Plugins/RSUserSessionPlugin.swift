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
    private var previousAutoSessionTrackingStatus: Bool?
    private static var shared: RSUserSessionPlugin?
    
    required init() {}
    
    func initialSetup() {
        self.sessionTimeOut = client?.config?.sessionTimeout
        self.sessionId = RSUserDefaults.getSessionId()
        self.lastEventTimeStamp = RSUserDefaults.getLastEventTimeStamp()
        self.previousAutoSessionTrackingStatus = RSUserDefaults.getAutoSessionTrackingStatus()
        startNewSessionIfRequired()
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
            if var context = workingMessage.context {
                if let sessionId = self.sessionId {
                    context[keyPath: "sessionId"] = sessionId
                    if isNewSessionStarted {
                        context[keyPath: "sessionStart"] = true
                        isNewSessionStarted = false
                    }
                } else {
                    client?.log(message: "SessionId is missing", logLevel: .warning)
                    print("Abhishek SessionId is missing")
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
        
        if isSessionTrackingAllowed() {
            if isSessionExpired() ||
                (!previousAutoSessionTrackingStatus && currentAutoSessionTrackingStatus) {
                startNewSession()
            }
        }
    }
    
    private func isSessionTrackingAllowed() -> Bool {
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
            // It'll return true only when the SDK is initialised for the first time
            return true
        }
        
        let timeDifference: TimeInterval = TimeInterval(abs(RSUtils.getTimeStamp() - lastEventTimeStamp))
        print ("Abhishek \(timeDifference)")
        if timeDifference >= Double(sessionTimeOut / 1000) {
            return true
        }
        return false
    }
    
    private func startNewSession() {
        print("Abhishek: New session starts")
        client?.log(message: "New session is started", logLevel: .verbose)
        isNewSessionStarted = true
        let sessionId = RSUtils.getTimeStamp()
        RSUserDefaults.saveSessionId(sessionId)
        self.sessionId = sessionId
    }
    
//    private func getSessionId() -> Int {
//        return self.sessionId ?? {
//            return startNewSession()
//        }()
//    }
//
//    private func clearSession() {
//        self.sessionId = nil
//        RSUserDefaults.clearSessionId()
//        RSUserDefaults.clearLastEventTimeStamp()
//    }
//
//    private func saveSessionTiming() {
//        if let sessionId = self.sessionId {
//            RSUserDefaults.saveSessionId(sessionId)
//        }
//    }
//
//    private func saveLastEventTimeStamp() {
//        if let lastEventTimeStamp = self.lastEventTimeStamp {
//            RSUserDefaults.saveLastEventTimeStamp(lastEventTimeStamp)
//        }
//    }
//
//    private func assignNewSessionId() {
//
//    }
//
//    private func saveAutoTrackingStatus() {
//        if let lastEventTimeStamp = self.lastEventTimeStamp {
//            RSUserDefaults.saveAutoTrackingStatus(lastEventTimeStamp)
//        }
//    }
//
//    private func getSessionId() -> Int {
//        if let sessionId = self.sessionId {
//            return sessionId
//        }
//        else if let sessionId = RSUserDefaults.getSessionId() {
//            self.sessionId = sessionId
//            return sessionId
//        }
//        else {
//            let sessionId = RSUtils.getTimeStamp()
//            self.sessionId = sessionId
//            return sessionId
//        }
//    }

}

extension RSClient {
    /**
     API for setting identifier under context.device.advertisingId.
     - Parameters:
     - advertisingId: IDFA value
     # Example #
     ```
     client.setAdvertisingId("sample_device_token")
     ```
     */
//    @objc
//    public func setAdvertisingId(_ advertisingId: String) {
//        guard advertisingId.isNotEmpty else {
//            log(message: "advertisingId can not be empty", logLevel: .warning)
//            return
//        }
//        if let advertisingIdPlugin = self.find(pluginType: RSAdvertisingIdPlugin.self) {
//            advertisingIdPlugin.advertisingId = advertisingId
//        } else {
//            let advertisingIdPlugin = RSAdvertisingIdPlugin()
//            advertisingIdPlugin.advertisingId = advertisingId
//            add(plugin: advertisingIdPlugin)
//        }
//    }
    
    @objc
    public func startSession() {
        
    }
    
    @objc
    public func startSession(sessionId: Int) {
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
        
    }
}
