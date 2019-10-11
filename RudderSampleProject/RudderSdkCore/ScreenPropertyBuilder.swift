//
//  ScreenPropertyBuilder.swift
//  RudderSdkCore
//
//  Created by Arnab Pal on 11/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

public class ScreenPropertyBuilder : NSObject {
    private var name: String? = nil
    
    public func setName(name: String) -> ScreenPropertyBuilder {
        self.name = name
        return self
    }
    
    public func build() -> Dictionary<String, NSObject>? {
        if (self.name == nil || self.name!.isEmpty) {
            RudderLogger.logError(message: "name can not be nil or empty")
            return nil
        }
        var property: Dictionary<String, NSObject> = Dictionary()
        property["name"] = self.name! as NSObject
        return property
    }
}
