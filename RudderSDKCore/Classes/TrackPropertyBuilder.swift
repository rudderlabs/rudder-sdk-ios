//
//  TrackPropertyBuilder.swift
//  RudderSdkCore
//
//  Created by Arnab Pal on 11/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

public class TrackPropertyBuilder {
    public init() {
        
    }
    
    private var category: String? = nil
    
    public func setCategory(category: String) -> TrackPropertyBuilder {
        self.category = category
        return self
    }
    
    private var label: String? = nil
    
    public func setLabel(label: String) -> TrackPropertyBuilder {
        self.label = label
        return self
    }
    
    private var value: String? = nil
    
    public func setValue(value: String) -> TrackPropertyBuilder {
        self.value = value
        return self
    }
    
    public func build() -> Dictionary<String, NSObject>? {
        if (self.category == nil) {
            RudderLogger.logError(message: "category can not be nil for track")
            return nil
        }
        
        var property: Dictionary<String, NSObject> = Dictionary();
        property["category"] = self.category as NSObject?
        
        if (self.label != nil) {
            property["label"] = self.label as NSObject?
        }
        
        if (self.value != nil) {
            property["value"] = self.value as NSObject?
        }
        
        return property
    }
}
