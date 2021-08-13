//
//  RSContext.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import WebKit

struct RSContext {
    static let RSATTNotDetermined: Int = 0
    static let RSATTRestricted: Int = 1
    static let RSATTDenied: Int = 2
    static let RSATTAuthorize: Int = 3
    
    let preferenceManager: RSPreferenceManager
    
    let app: RSApp
    var traits: [String:Any]?
    let library: RSLibraryInfo
    let os: RSOSInfo
    let screen: RSScreenInfo
    let userAgent: String?
    let locale: String
    var device: RSDeviceInfo
    let network: RSNetwork
    let timezone: String
    var externalIds: [[ String: Any]]?
    
    init() {
        self.preferenceManager = RSPreferenceManager.getInstance()
        self.app = RSApp()
        self.device = RSDeviceInfo()
        self.library = RSLibraryInfo()
        self.os = RSOSInfo()
        self.screen = RSScreenInfo()
        self.userAgent = WKWebView().value(forKey: "userAgent") as? String
        self.locale = RSUtils.getLocale()
        self.network = RSNetwork()
        self.timezone = NSTimeZone.local.identifier
        
        self.externalIds = nil
        self.traits = nil
        
        let traitsJson: String? = self.preferenceManager.getTraits()
        if(traitsJson == nil)
        {
            createAndPersistTraits()
        }
        else
        {
            do {
                if let serializedTraits = try JSONSerialization.jsonObject(with: Data(traitsJson!.utf8), options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
                    self.traits = serializedTraits
                }
                else{
                    createAndPersistTraits()
                }
            }
            catch _ as NSError {
                createAndPersistTraits()
            }
        }
        
        let externalIdsJson: String? = self.preferenceManager.getExternalIds()
        if(externalIdsJson != nil)
        {
            do {
                if let serializedExternalIds = try JSONSerialization.jsonObject(with: Data(externalIdsJson!.utf8), options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String : Any]] {
                    self.externalIds = serializedExternalIds
                }
            }
            catch _ as NSError {
            }
        }
        
    }
    
    mutating func createAndPersistTraits() {
        let traits: RSTraits = RSTraits()
        traits.anonymousId = preferenceManager.getAnonymousId()
        self.traits = traits.dict()
        persistTraits()
    }
    
    func persistTraits()
    {
        do {
            let traitsData = try JSONSerialization.data(withJSONObject: self.traits!, options: .prettyPrinted)
            let traitsString = String(data:traitsData, encoding:.utf8)!
            preferenceManager.saveTraits(traits: traitsString)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    mutating func updateTraitsDict(traitsDict:[String:Any]) {
        var updatedTraits = traitsDict
        let anonymousId:String? = preferenceManager.getAnonymousId()
        if(anonymousId == nil)
        {
            updatedTraits["anonymousId"] = self.device.identifier
        }
        self.traits = updatedTraits
    }
    
    mutating func putDeviceToken(deviceToken: String)
    {
        self.device.token = deviceToken
    }
    
    mutating func putAdvertisementId(idfa: String)
    {
        //             This isn't ideal.  We're doing this because we can't actually check if IDFA is enabled on
        //             the customer device.  Apple docs and tests show that if it is disabled, one gets back all 0's.
        //             [RSLogger logDebug:[[NSString alloc] initWithFormat:@"IDFA: %@", idfa]];
        let adTrackingEnabled: Bool = idfa == "00000000-0000-0000-0000-000000000000"
        self.device.adTrackingEnabled = adTrackingEnabled
        if(adTrackingEnabled)
        {
            self.device.advertisingId = idfa
        }
        
    }
    
    mutating func updateExternalIds(externalIds: [[String:Any]]){
        self.externalIds = externalIds
        do {
            let externalIdData = try JSONSerialization.data(withJSONObject: self.externalIds!, options: .prettyPrinted)
            let externalIdJson = String(data:externalIdData, encoding:.utf8)!
            preferenceManager.saveExternalIds(externalIdsJson: externalIdJson)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    mutating func putAppTrackingConsent(att:Int)
    {
        if (att < RSContext.RSATTNotDetermined) {
            self.device.attTrackingStatus = RSContext.RSATTNotDetermined;
        } else if (att > RSContext.RSATTAuthorize) {
            self.device.attTrackingStatus = RSContext.RSATTAuthorize;
        } else {
            self.device.attTrackingStatus = att;
        }
    }
    
    func dict() -> [String:Any] {
        var tempDict:[String:Any] = [:]
        tempDict["app"] = app.dict()
        tempDict["traits"] = traits
        tempDict["library"] = library.dict()
        tempDict["os"] = os.dict()
        tempDict["screen"] = screen.dict()
        if(userAgent != nil)
        {
            tempDict["userAgent"] = userAgent
        }
        tempDict["locale"] = locale
        tempDict["device"] = device.dict()
        tempDict["network"] = network.dict()
        tempDict["timezone"] = timezone
        tempDict["externalId"] = externalIds
        return tempDict
    }
    
}
