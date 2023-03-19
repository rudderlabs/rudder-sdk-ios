//
//  CustomFilter.swift
//  RudderSampleAppSwift
//
//  Created by Pallab Maiti on 15/02/23.
//  Copyright © 2023 RudderStack. All rights reserved.
//

import Foundation
import Rudder

class CustomFilter: RSConsentFilter {
    func filterConsentedDestinations(_ destinations: [RSServerDestination]) -> [String : NSNumber]? {
        return [:]
    }
    
    func getConsentCategoriesDict() -> [String : NSNumber]? {
        return [:]
    }
}
