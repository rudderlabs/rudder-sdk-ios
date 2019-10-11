//
//  RudderServerConfigManager.swift
//  RudderSdkCore
//
//  Created by Arnab Pal on 11/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

class RudderServerConfigManager {
    private static var instance: RudderServerConfigManager? = nil
    private var serverConfig: RudderServerConfig?
    let preferences = UserDefaults.standard
    var writeKey: String
    
    private init(_writeKey: String) {
        self.writeKey = _writeKey
        self.serverConfig = self.retrieveConfig()
        if (self.serverConfig == nil || self.isServerConfigOutdated()) {
            Thread(block: downloadConfig).start()
        }
    }
    
    static func getInstance(writeKey: String) -> RudderServerConfigManager {
        if (instance == nil) {
            instance = RudderServerConfigManager(_writeKey: writeKey)
        }
        
        return instance!
    }
    
    private func isServerConfigOutdated() -> Bool {
        let currentTime: Int32 = Utils.gettimeStampLong()
        let lastUpdatedTime : Int32 = Int32(preferences.integer(forKey: "rl_server_update_time"))
        return (currentTime - lastUpdatedTime) > (24 * 60 * 60 * 1000);
    }
    
    private func retrieveConfig() -> RudderServerConfig? {
        if (preferences.object(forKey: "rl_server_config") == nil) {
            return nil
        } else {
            let configJson = preferences.string(forKey: "rl_server_config")
            if (configJson == nil) {
                return nil
            } else {
                return self.parseConfig(configJson: configJson!)
            }
        }
    }
    
    private func parseConfig(configJson: String) -> RudderServerConfig? {
        let configData = configJson.data(using: .utf8)
        
        let decoder = JSONDecoder()
        
        do {
            if (configData != nil) {
                return try decoder.decode(RudderServerConfig.self, from: configData!)
            } else {
                RudderLogger.logError(message: "unreadable config")
                return nil
            }
        } catch {
            RudderLogger.logError(error: error)
            return nil
        }
    }
    
    private func downloadConfig() {
        var isDone: Bool = false
        var retryCount: Int = 0
        
        while(!isDone || retryCount <= 3) {
            let configJson = makeNetworkRequest()
            
            if (configJson != nil) {
                preferences.set(configJson, forKey: "rl_server_config")
                preferences.set(Utils.gettimeStampLong(), forKey: "rl_server_update_time")
                
                self.serverConfig = parseConfig(configJson: configJson!)
                
                isDone = true
            } else {
                retryCount += 1
                usleep(useconds_t(10000000 * retryCount))
            }
        }
    }
    
    private func makeNetworkRequest() -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        let configUrl = "https://api.rudderlabs.com/source-config?write_key="+self.writeKey
        let url = URL(string: configUrl)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        var response: String? = nil
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, result, error) in
            if (data != nil) {
                response = String(data: data!, encoding: String.Encoding.utf8)
            } else {
                if (error != nil) {
                    RudderLogger.logError(error: error!)
                } else {
                    RudderLogger.logError(message: "unknown error")
                }
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return response
    }
    
    func getConfig() -> RudderServerConfig? {
        if (serverConfig == nil) {
            serverConfig = retrieveConfig()
        }
        return serverConfig
    }
}
