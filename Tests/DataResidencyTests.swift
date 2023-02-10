//
//  DataResidencyTests.swift
//  RudderTests
//
//  Created by Desu Sai Venkat on 26/10/22.
//

import XCTest
@testable import Rudder

class DataResidencyTests: XCTestCase {
    
    let writeKey = "123@23456"
    var rsConfig: RSConfig!
    var rsServerConfigManager: RSServerConfigManager!
    var rsServerConfigSource: RSServerConfigSource!
    var configJson: String!
    var testUtils: TestUtils!
    
    
    override func setUp() {
        super.setUp()
        testUtils = TestUtils()
    }
    
    override func tearDown() {
        super.tearDown()
        testUtils = nil
        rsConfig = nil
        rsServerConfigManager = nil
        rsServerConfigSource = nil
        configJson = nil
    }
    
    func testWithBothResidenciesInSourceConfig() {
        configJson = testUtils.getJSONString(forResource: "multi-dataresidency-default-true", ofType: "json")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig)
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-eu.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-eu.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
    }
    
    func testWithOnlyUSInSourceConfig() {
        configJson = testUtils.getJSONString(forResource: "us-dataresidency-default-true", ofType: "json")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig)
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
    }
    
    func testWithOnlyEUInSourceConfig() {
        configJson = testUtils.getJSONString(forResource: "eu-dataresidency-default-true", ofType: "json")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig)
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-eu.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-eu.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
    }
    
    func testWhenNoUrlInSourceConfig() {
        configJson = testUtils.getJSONString(forResource: "no-dataresidency", ofType: "json")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig)
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https::/somerandomdataplanecom").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
    }
    
    func testWithBothResidenciesInSourceConfig_DefaultFalse() {
        configJson = testUtils.getJSONString(forResource: "multi-dataresidency-default-false", ofType: "json")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig)
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
    }
    
    func testWithOnlyUSInSourceConfig_DefaultFalse() {
        configJson = testUtils.getJSONString(forResource: "us-dataresidency-default-false", ofType: "json")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig)
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
    }
    
    func testWithOnlyEUInSourceConfig_DefaultFalse() {
        configJson = testUtils.getJSONString(forResource: "eu-dataresidency-default-false", ofType: "json")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig)
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
    }
    
    func testWithBothResidenciesInSourceConfig_USTrue() {
        configJson = testUtils.getJSONString(forResource: "multi-dataresidency-us-true", ofType: "json")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig)
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
    }
    
    func testWithBothResidenciesInSourceConfig_EUTrue() {
        configJson = testUtils.getJSONString(forResource: "multi-dataresidency-eu-true", ofType: "json")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig)
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-eu.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.US).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(RSDataResidencyServer.EU).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-eu.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), nil)
    }
}
