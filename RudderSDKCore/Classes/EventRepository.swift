//
//  EventRepository.swift
//  RudderPlugin_iOS
//
//  Created by Arnab Pal on 14/09/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

class EventRepository {
    private var authHeader: String? = nil
    private var config: RudderConfig? = nil
    private var dbManager: DBPersistentManager? = nil
    private var configManager: RudderServerConfigManager? = nil
    private var integrationMap: Dictionary<String, Bool>? = nil
    private var integrationOperationMap: [String: RudderIntegration<NSObject>?] = [:]
    
    /*
     * constructor to be called from RudderClient internally.
     * -- tasks to be performed
     * 1. persist the value of config
     * 2. initiate RudderElementCache
     * 3. initiate DBPersistentManager for SQLite operations
     * 4. initiate RudderServerConfigManager
     * 5. start processor thread
     * 6. initiate factories
     * */
    init (_writeKey: String, _config: RudderConfig) {
        // 1. set the values of writeKey, config
        self.config = _config
        
        // create the auth header
        let authHeaderStr = _writeKey + ":"
        let utf8HeaderStr = authHeaderStr.data(using: .utf8)
        self.authHeader = utf8HeaderStr?.base64EncodedString()
        
        // 2. initiate RudderElementCache
        RudderElementCache.initiate()
        
        // 3. initiate DBPersistentManager for SQLite operations
        self.dbManager = DBPersistentManager.getInstance()
        
        // 4. initiate RudderServerConfigManager
        self.configManager = RudderServerConfigManager.getInstance(writeKey: _writeKey)
        
        // 5. start processor thread
        if #available(iOS 10.0, *) {
            let processorThread: Thread = Thread(block: processEvents)
            processorThread.start()
        }
        
        // 6. initiate factories
        self.initiateFactories(config: _config)
    }
    
    private func initiateFactories(config: RudderConfig) {
        if (configManager == nil || config.getFactories().isEmpty) {
            return
        }
        
        // get destinations from server
        let serverConfig: RudderServerConfig? = self.configManager!.getConfig()
        if (serverConfig?.source == nil) {
            return
        }
        
        let destinations = serverConfig?.source!.destinations
        var destinationMap: [String: RudderServerDestination] = [:]
        if (destinations != nil && !destinations!.isEmpty) {
            for index in 0..<destinations!.count {
                let destination: RudderServerDestination = destinations![index]
                destinationMap[destination.destinationDefinition!.name] = destination
            }
        }
        
        // check the factories integrated
        let factories = config.getFactories()
        for index in 0..<factories.count {
            let factory: RudderIntegration.Factory = factories[index]
            if (destinationMap[factory.key] != nil) {
                let destination: RudderServerDestination? = destinationMap[factory.key]
                if (destination != nil && destination!.enabled) {
                    let destinationConfig = destination?.config
                    
                    let integration: RudderIntegration<NSObject>? = factory.create(destinationConfig: destinationConfig, client: RudderClient.getInstance()!) as? RudderIntegration<NSObject>
                    self.integrationOperationMap[factory.key] = integration
                }
            }
        }
    }
    
    private func processEvents() {
        if (self.dbManager == nil) {
            return
        }
        
        var sleepCount: Int32 = 0
        
        while true {
            let dbRecordCount = self.dbManager!.getDBRecordCount()
            if (dbRecordCount > self.config!.getDbCountThreshold()) {
                let extraMsgs: RudderDBMessage = self.dbManager!.fetchEventsFromDB(count: dbRecordCount-self.config!.getDbCountThreshold())
                self.dbManager?.clearEventsFromDB(messageIds: extraMsgs.messageIds)
            }
            let dbMessages = self.dbManager!.fetchEventsFromDB(count: self.config!.getFlushQueueSize())
            if (dbMessages.messages.count > 0 && sleepCount>=self.config!.getSleepTimeOut()) {
                let payload: String = self.getPayloadFromMessages(messages: dbMessages.messages)
                let response = self.flushEventsToServer(payload: payload)
                if (response == nil) {
                    RudderLogger.logError(message: "Blank response from server")
                } else {
                    RudderLogger.logInfo(message: "response: " + response! + " || count: " + String(dbMessages.messages.count))
                }
                if (response != nil && response!.elementsEqual("OK")) {
                    self.dbManager!.clearEventsFromDB(messageIds: dbMessages.messageIds)
                    sleepCount = 0
                }
            }
            sleepCount += 1
            usleep(1000000)
        }
    }
    
    private func getPayloadFromMessages(messages: [String]) -> String {
        let sentAt = Utils.getTimeStampStr()
        var payload: String = ""
        payload.append("{")
        payload.append("\"sentAt\":\"")
        payload.append(sentAt)
        payload.append("\",")
        payload.append("\"batch\":[")
        for index in 0..<messages.count {
            var message: String = messages[index]
            message = String(message.prefix(message.count - 1))
            message = message + ", \"sentAt\": \""+sentAt+"\"}"
            payload.append(message)
            if (index != messages.count-1) {
                payload.append(",")
            }
        }
        payload.append("]")
        payload.append("}")
        return payload
    }
    
    private func flushEventsToServer(payload: String) -> String? {
        if (self.authHeader == nil) {
            RudderLogger.logError(message: "writeKey is in incorrect format")
            return nil
        }
        let semaphore = DispatchSemaphore(value: 0)
        let endPointUrl = self.config!.getEndPointUrl() + "/v1/batch"
        let url = URL(string: endPointUrl)
        var urlRequest = URLRequest(url: url!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Basic " + self.authHeader!, forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = Data(payload.utf8)
        var response: String? = nil
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, result, error) in
            if (data != nil) {
                response = String(data: data!, encoding: String.Encoding.utf8)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return response
    }

    
    func dump(message: RudderMessage) throws {
        if (self.integrationMap == nil) {
            self.prepareIntegrations()
        }
        message.setIntegrations(integrations: self.integrationMap!)
        for (_, integration) in self.integrationOperationMap {
            if (integration != nil) {
                integration!.dump(message: message)
            }
        }
        let encoder = JSONEncoder()
        let eventJson = try encoder.encode(message)
        let eventString = String(data: eventJson, encoding: .utf8)
        self.dbManager!.saveEvent(messageJson: eventString!)
    }
    
    func prepareIntegrations() {
        self.integrationMap = Dictionary()
        
        let source: RudderServerConfigSource? = self.configManager?.getConfig()?.source
        if (source == nil) {
            return
        }
        
        let destinations = source!.destinations
        if (destinations.isEmpty) {
            return
        }
        
        self.integrationMap = Dictionary()
        for (destination) in destinations {
            if (destination.destinationDefinition != nil) {
                if (self.integrationMap![destination.destinationDefinition!.name] == nil) {
                    self.integrationMap![destination.destinationDefinition!.name] = destination.enabled
                }
            }
        }
    }
}
