//
//  RSServiceType.swift
//  RudderStack
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

protocol RSServiceType {
    func downloadServerConfig(_ completion: @escaping Handler<RSServerConfig>)
    
    func flushEvents(params: String, _ completion: @escaping Handler<Bool>)
}
