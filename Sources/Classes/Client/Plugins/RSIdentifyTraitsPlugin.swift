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
        if let traits = traits {
            do {
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: traits, requiringSecureCoding: false)
                RSUserDefaults.saveTraits(data)
            } catch {
                self.client?.log(message: "Failed to encode traits: \(error)", logLevel: .error)
            }
        }
    }
}

extension RSClient {
    internal func setTraits(_ traits: IdentifyTraits?) {
        guard var traits = traits else { return }
        if let traitsPlugin = self.find(pluginType: RSIdentifyTraitsPlugin.self) {
            if let traitsPluginTraits = traitsPlugin.traits {
                traits.merge(traitsPluginTraits) { (_, new) in new }
            }
            traitsPlugin.traits = traits
            traitsPlugin.saveTraits(traits)
        } else {
            let traitsPlugin = RSIdentifyTraitsPlugin()
            traitsPlugin.traits = traits
            traitsPlugin.saveTraits(traits)
            add(plugin: traitsPlugin)
        }
    }
}
