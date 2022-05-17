//
//  RSErrorCode.swift
//  RudderStack
//
//  Created by Pallab Maiti on 19/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

enum RSErrorCode: Int {
    case UNKNOWN = -1
    case WRONG_WRITE_KEY = 0
    case DECODING_FAILED = 1
    case SERVER_ERROR = 500
}
