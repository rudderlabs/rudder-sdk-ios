//
//  Data+Ext.swift
//  Rudder
//
//  Created by Pallab Maiti on 16/07/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        return map { String(format: "%02.2hhx", $0) }.joined()
    }
}
