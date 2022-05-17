//
//  RSAppTrackingConsent.swift
//  RudderStack
//
//  Created by Pallab Maiti on 10/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@frozen @objc public enum RSAppTrackingConsent: Int {
    case authorize = 3
    case denied = 2
    case restricted = 1
    case notDetermined = 0
}
