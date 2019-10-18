//
//  RudderElementCache.swift
//  RudderSample
//
//  Created by Arnab Pal on 28/08/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

class RudderElementCache {
    private static var cachedContext: RudderContext? = nil;
    
    static func initiate() {
        if (cachedContext == nil) {
            cachedContext = RudderContext()
        }
    }
    
    static func getCachedContext() -> RudderContext {
        return cachedContext!;
    }
    
}
