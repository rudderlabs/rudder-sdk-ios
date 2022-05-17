//
//  RSOptionPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 02/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSOptionPlugin: RSPlatformPlugin {
    let type: PluginType = .before
    var client: RSClient?
    
    var option: RSOption?
    
    required init() { }
}

extension RSClient {
    /**
     API for setting enable/disable sending the events across all the event calls made using the SDK to the specified destinations.
     - Parameters:
        - option: Options related to every API call
     # Example #
     ```
     let defaultOption = RSOption()
     defaultOption.putIntegration("Amplitude", isEnabled: true)
     
     client.setOption(defaultOption)
     ```
     */
    @objc
    public func setOption(_ option: RSOption) {
        if let optionPlugin = self.find(pluginType: RSOptionPlugin.self) {
            optionPlugin.option = option
        } else {
            let optionPlugin = RSOptionPlugin()
            optionPlugin.option = option
            add(plugin: optionPlugin)
        }
    }
}
