//
//  RudderIntegration.swift
//  RudderSdkCore
//
//  Created by Arnab Pal on 09/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

public class RudderIntegration<T> {
    
    public class Factory {
        public var key: String = ""
        
        public func create(destinationConfig: NSObject?, client: RudderClient) -> T? {
            // to be overridden in actual implementation
            return nil
        }
    }
    
    public func dump(message: RudderMessage) {
        // to be overridden in actual implementation
    }
    
}
