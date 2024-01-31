//
//  DefaultsPersistenceTests.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 31/01/24.
//

import XCTest
import Foundation
@testable import Rudder


class DefaultsPersistenceTests: XCTestCase {
    
    override func tearDown() {
        clearStandardDefaults()
        RSUtils.removeFile("rsDefaultsPersistence.plist")
        super.tearDown()
    }
    
    func testCopyingFromStandardDefaults() {
        UserDefaults.standard.setValue("{\"name\": \"John\"}", forKey: RSTraitsKey)
        UserDefaults.standard.setValue(true, forKey: RSOptStatus)
        UserDefaults.standard.setValue("1.4.6", forKey: RSApplicationInfoKey)
        UserDefaults.standard.setValue(1706686540, forKey: RSLastActiveTimestamp)
        UserDefaults.standard.setValue("RudderStack", forKey: "Company")
        
        let defaultsPersistence = RSDefaultsPersistence.sharedInstance()
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSTraitsKey) as? String, "{\"name\": \"John\"}")
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSOptStatus) as? Bool, true)
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSApplicationInfoKey) as? String, "1.4.6")
        XCTAssertNil(defaultsPersistence?.readObject(forKey: "Company"))
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSLastActiveTimestamp) as? Int, 1706686540)
    }
    
    func testIfFallingBackToPersistenceLayer() {
        
        let preferenceManager = RSPreferenceManager.getInstance()
        preferenceManager.saveTraits("{\"name\": \"John\"}")
        preferenceManager.saveOptStatus(true)
        preferenceManager.saveBuildVersionCode("1.4.6")
        preferenceManager.saveLastActiveTimestamp(1706686540)
        
        XCTAssertEqual(preferenceManager.getTraits() as String, "{\"name\": \"John\"}")
        
        // now simulate that the app developer directly clears the standard defaults
        // and check if the preference manager is falling back to persistence layer
        clearStandardDefaults()
        XCTAssertEqual(preferenceManager.getTraits() as String, "{\"name\": \"John\"}")
        XCTAssertEqual(preferenceManager.getOptStatus(), true)
        XCTAssertEqual(preferenceManager.getBuildVersionCode(), "1.4.6")
        XCTAssertEqual(preferenceManager.getLastActiveTimestamp(), 1706686540)
    }
    
    func clearStandardDefaults() {
        let defaultsDict = UserDefaults.standard.dictionaryRepresentation()
        for key in defaultsDict.keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
