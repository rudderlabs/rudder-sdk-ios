//
//  RSIdentifyTraitsPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 31/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSIdentifyTraitsPlugin: RSPlatformPlugin {
    let type = PluginType.before
    var client: RSClient? {
        didSet {
            initialSetup()
        }
    }
    
    var traits: IdentifyTraits?

    required init() { }
    
    func initialSetup() {
        if let data: Data = RSUserDefaults.getTraits() {
            do {
                if let dictionary = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: Any] {
                    traits = dictionary
                }
            } catch {
                self.client?.log(message: "Failed to decode traits: \(error)", logLevel: .error)
            }
        }
    }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        if let traits = traits {
            if var context = workingMessage.context {
                context["traits"] = traits
                workingMessage.context = context
                client?.updateContext(context)
            }
        }
        return workingMessage
    }
}

extension RSIdentifyTraitsPlugin: RSEventPlugin {
    func reset() {
        traits = nil
        RSUserDefaults.saveTraits(nil)
    }
    
    func saveTraits(_ traits: [String: Any]?) {
        guard let traits = traits else {
            RSUserDefaults.saveTraits(nil)
            return
        }
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: traits, requiringSecureCoding: false)
            RSUserDefaults.saveTraits(data)
        } catch {
            self.client?.log(message: "Failed to encode traits: \(error)", logLevel: .error)
        }
    }
}

extension RSClient {
    internal func setTraits(_ traits: IdentifyTraits?, _ newUserId: String) {
        if let traitsPlugin = self.find(pluginType: RSIdentifyTraitsPlugin.self) {
            var updatedTraits = traits
            if let exisitingUserId = RSUserDefaults.getUserId(), exisitingUserId == newUserId {
                if var existingTraits = traitsPlugin.traits, let newTraits = traits {
                    existingTraits.merge(newTraits) { (_, new) in new }
                    updatedTraits = existingTraits
                }
            }
            updatedTraits = (updatedTraits != nil) ? updatedTraits : traitsPlugin.traits
            traitsPlugin.traits = updatedTraits
            traitsPlugin.saveTraits(updatedTraits)
        } else {
            let traitsPlugin = RSIdentifyTraitsPlugin()
            traitsPlugin.traits = traits
            traitsPlugin.saveTraits(traits)
            add(plugin: traitsPlugin)
        }
    }
}
