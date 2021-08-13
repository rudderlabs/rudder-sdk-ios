//
//  RSMessage.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

struct RSMessage {
    
    let messageId: String
    let channel: String
    var context: RSContext?
    var type: String?
    var action: String?
    let originalTimeStamp: String
    var anonymousId: String?
    var userId: String?
    var previousId: String?
    var groupId: String?
    var traits: [String:Any]?
    var event: String?
    var properties: [String:Any]?
    var userProperties: [String:Any]?
    var integrations: [String:Any]?
    var customContexts: [String:[String:Any]]?
    var destinationsProps: String?
    var option: RSOption?
    
    init() {
        messageId = String(format: "%ld-%@", RSUtils.getTimeStampLong(), RSUtils.getUniqueId())
        channel = "mobile"
        //        context = RSElementCache.getContext()
        originalTimeStamp = RSUtils.getTimeStamp()
        previousId = nil
        groupId = nil
        traits = nil
        userProperties = nil
        anonymousId = RSPreferenceManager.getInstance().getAnonymousId()
    }
    
}

