//
//  NSError+Ext.swift
//  RudderStack
//
//  Created by Pallab Maiti on 19/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

extension NSError {
    convenience init(code: RSErrorCode) {
        self.init(domain: "RSError", code: code.rawValue, userInfo: nil)
    }
}
