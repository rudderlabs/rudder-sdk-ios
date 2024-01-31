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
    
    override func setUp() {
        clearDefaults()
        RSDefaultsPersistence.sharedInstance().clearState()
        super.setUp()
    }
    
    override func tearDown() {
        clearDefaults()
        RSDefaultsPersistence.sharedInstance().clearState()
        super.tearDown()
    }
    
    func testCopyingFromStandardDefaultsIfNeeded() {
        UserDefaults.standard.setValue("{\"name\": \"John\"}", forKey: RSTraitsKey)
        UserDefaults.standard.setValue(false, forKey: RSOptStatus)
        UserDefaults.standard.setValue("1.4.4", forKey: RSApplicationInfoKey)
        UserDefaults.standard.setValue(1706686541, forKey: RSLastActiveTimestamp)
        UserDefaults.standard.setValue("RudderStack India", forKey: "Company")
        
        let defaultsPersistence = RSDefaultsPersistence.sharedInstance()
        defaultsPersistence?.clearState()
        defaultsPersistence?.copyStandardDefaultsToPersistenceIfNeeded()
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSTraitsKey) as? String, "{\"name\": \"John\"}")
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSOptStatus) as? Bool, false)
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSApplicationInfoKey) as? String, "1.4.4")
        XCTAssertNil(defaultsPersistence?.readObject(forKey: "Company"))
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSLastActiveTimestamp) as? Int, 1706686541)
    }
    
    func testIfFallingBackToPersistenceLayer() {
        
        let preferenceManager = RSPreferenceManager.getInstance()
        preferenceManager.saveTraits("{\"name\": \"Adam\"}")
        preferenceManager.saveOptStatus(false)
        preferenceManager.saveBuildVersionCode("1.4.5")
        preferenceManager.saveLastActiveTimestamp(1706686542)
        
        XCTAssertEqual(preferenceManager.getTraits() as String, "{\"name\": \"Adam\"}")
        
        // now simulate that the app developer directly clears the standard defaults
        // and check if the preference manager is falling back to persistence layer
        clearDefaults()
        XCTAssertEqual(preferenceManager.getTraits() as String, "{\"name\": \"Adam\"}")
        XCTAssertEqual(preferenceManager.getOptStatus(), false)
        XCTAssertEqual(preferenceManager.getBuildVersionCode(), "1.4.5")
        XCTAssertEqual(preferenceManager.getLastActiveTimestamp(), 1706686542)
    }
    
    func testRestoringDefaultsFromPersistence() {
        let preferenceManager = RSPreferenceManager.getInstance()
        preferenceManager.saveTraits("{\"name\": \"David\"}")
        preferenceManager.saveOptStatus(true)
        preferenceManager.saveBuildVersionCode("1.4.6")
        preferenceManager.saveLastActiveTimestamp(1706686543)
        
        XCTAssertEqual(preferenceManager.getTraits() as String, "{\"name\": \"David\"}")
        
        clearDefaults()
        
        // preference manager would return back the values from persistence layer but the value in user defaults should be nil now
        XCTAssertEqual(preferenceManager.getTraits() as String, "{\"name\": \"David\"}")
        XCTAssertNil(UserDefaults.standard.value(forKey: RSTraitsKey))
        XCTAssertEqual(preferenceManager.getOptStatus(), true)
        XCTAssertNil(UserDefaults.standard.value(forKey: RSOptStatus))
        XCTAssertEqual(preferenceManager.getBuildVersionCode(), "1.4.6")
        XCTAssertNil(UserDefaults.standard.value(forKey: RSApplicationInfoKey))
        XCTAssertEqual(preferenceManager.getLastActiveTimestamp(), 1706686543)
        XCTAssertNil(UserDefaults.standard.value(forKey: RSLastActiveTimestamp))
        
        // now we are restoring the missing keys to defaults from persistence, post which defaults should contain the values
        preferenceManager.restoreMissingKeysFromPersistence()
        
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSTraitsKey) as? String, "{\"name\": \"David\"}")
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSOptStatus) as? Bool, true)
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSApplicationInfoKey) as? String, "1.4.6")
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSLastActiveTimestamp) as? Int, 1706686543)
    }
    
    func clearDefaults() {
        for key in [RSTraitsKey, RSOptStatus, RSApplicationInfoKey, RSLastActiveTimestamp, "Company"] {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
