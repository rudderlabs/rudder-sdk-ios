//
//  RudderConfig.swift
//  RudderOneTrust
//
//  Created by Pallab Maiti on 26/01/23.
//

import Foundation

@objc
class RudderConfig: NSObject, Codable {
    @objc let WRITE_KEY: String
    @objc let PROD_DATA_PLANE_URL: String
    @objc let PROD_CONTROL_PLANE_URL: String
    @objc let LOCAL_DATA_PLANE_URL: String
    @objc let LOCAL_CONTROL_PLANE_URL: String
    @objc let DEV_DATA_PLANE_URL: String
    @objc let DEV_CONTROL_PLANE_URL: String
    @objc let STORAGE_LOCATION: String
    @objc let DOMAIN_IDENTIFIER: String
    
    @objc
    class func create(from url: URL) -> RudderConfig? {
        if let data = try? Data(contentsOf: url),
           let rudderConfig = try? PropertyListDecoder().decode(RudderConfig.self, from: data) {
            return rudderConfig
        }
        return nil
    }
}
