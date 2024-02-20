//
//  DataResidencyTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 09/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

let EU = "https://rudderstacgwyx-eu.dataplane.rudderstack.com"
let US = "https://rudderstacgwyx-us.dataplane.rudderstack.com"

final class DataResidencyTests: XCTestCase {
     
    func testWithBothResidenciesInSourceConfig_1() {
        let sourceConfig: SourceConfig = MultiDataResidency.defaultTrue
        let config: Config = .mockWith()
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNotNil(dataResidency.dataPlaneUrl)
        XCTAssertTrue(dataResidency.dataPlaneUrl == US)
    }
    
    func testWithBothResidenciesInSourceConfig_2() {
        let sourceConfig: SourceConfig = MultiDataResidency.defaultTrue
        let config: Config = .mockWith(dataResidencyServer: .EU)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNotNil(dataResidency.dataPlaneUrl)
        XCTAssertTrue(dataResidency.dataPlaneUrl == EU)
    }
     
    func testWithBothResidenciesInSourceConfig_3() {
        let sourceConfig: SourceConfig = MultiDataResidency.defaultTrue
        let config: Config = .mockWith(dataResidencyServer: .US)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNotNil(dataResidency.dataPlaneUrl)
        XCTAssertTrue(dataResidency.dataPlaneUrl == US)
    }
    
    func testWithBothResidenciesInSourceConfig_DefaultFalse_1() {
        let sourceConfig: SourceConfig = MultiDataResidency.defaultFalse
        let config: Config = .mockWith()
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithBothResidenciesInSourceConfig_DefaultFalse_2() {
        let sourceConfig: SourceConfig = MultiDataResidency.defaultFalse
        let config: Config = .mockWith(dataResidencyServer: .EU)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithBothResidenciesInSourceConfig_DefaultFalse_3() {
        let sourceConfig: SourceConfig = MultiDataResidency.defaultFalse
        let config: Config = .mockWith(dataResidencyServer: .US)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }

    func testWithBothResidenciesInSourceConfig_USTrue_1() {
        let sourceConfig: SourceConfig = MultiDataResidency.USTrue
        let config: Config = .mockWith()
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNotNil(dataResidency.dataPlaneUrl)
        XCTAssertTrue(dataResidency.dataPlaneUrl == US)
    }
    
    func testWithBothResidenciesInSourceConfig_USTrue_2() {
        let sourceConfig: SourceConfig = MultiDataResidency.USTrue
        let config: Config = .mockWith(dataResidencyServer: .EU)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithBothResidenciesInSourceConfig_USTrue_3() {
        let sourceConfig: SourceConfig = MultiDataResidency.USTrue
        let config: Config = .mockWith(dataResidencyServer: .US)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNotNil(dataResidency.dataPlaneUrl)
        XCTAssertTrue(dataResidency.dataPlaneUrl == US)
    }
    
    func testWithBothResidenciesInSourceConfig_EUTrue_1() {
        let sourceConfig: SourceConfig = MultiDataResidency.EUTrue
        let config: Config = .mockWith()
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithBothResidenciesInSourceConfig_EUTrue_2() {
        let sourceConfig: SourceConfig = MultiDataResidency.EUTrue
        let config: Config = .mockWith(dataResidencyServer: .EU)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNotNil(dataResidency.dataPlaneUrl)
        XCTAssertTrue(dataResidency.dataPlaneUrl == EU)
    }
    
    func testWithBothResidenciesInSourceConfig_EUTrue_3() {
        let sourceConfig: SourceConfig = MultiDataResidency.EUTrue
        let config: Config = .mockWith(dataResidencyServer: .US)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }

    func testWithOnlyUSInSourceConfig_1() {
        let sourceConfig: SourceConfig = USDataResidency.defaultTrue
        let config: Config = .mockWith()
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNotNil(dataResidency.dataPlaneUrl)
        XCTAssertTrue(dataResidency.dataPlaneUrl == US)
    }
    
    func testWithOnlyUSInSourceConfig_2() {
        let sourceConfig: SourceConfig = USDataResidency.defaultTrue
        let config: Config = .mockWith(dataResidencyServer: .EU)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNotNil(dataResidency.dataPlaneUrl)
        XCTAssertTrue(dataResidency.dataPlaneUrl == US)
    }
    
    func testWithOnlyUSInSourceConfig_3() {
        let sourceConfig: SourceConfig = USDataResidency.defaultTrue
        let config: Config = .mockWith(dataResidencyServer: .US)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNotNil(dataResidency.dataPlaneUrl)
        XCTAssertTrue(dataResidency.dataPlaneUrl == US)
    }
    
    func testWithOnlyUSInSourceConfig_DefaultFalse_1() {
        let sourceConfig: SourceConfig = USDataResidency.defaultFalse
        let config: Config = .mockWith()
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithOnlyUSInSourceConfig_DefaultFalse_2() {
        let sourceConfig: SourceConfig = USDataResidency.defaultFalse
        let config: Config = .mockWith(dataResidencyServer: .EU)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithOnlyUSInSourceConfig_DefaultFalse_3() {
        let sourceConfig: SourceConfig = USDataResidency.defaultFalse
        let config: Config = .mockWith(dataResidencyServer: .US)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithOnlyEUInSourceConfig_1() {
        let sourceConfig: SourceConfig = EUDataResidency.defaultTrue
        let config: Config = .mockWith()
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithOnlyEUInSourceConfig_2() {
        let sourceConfig: SourceConfig = EUDataResidency.defaultTrue
        let config: Config = .mockWith(dataResidencyServer: .EU)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNotNil(dataResidency.dataPlaneUrl)
        XCTAssertTrue(dataResidency.dataPlaneUrl == EU)
    }
    
    func testWithOnlyEUInSourceConfig_3() {
        let sourceConfig: SourceConfig = EUDataResidency.defaultTrue
        let config: Config = .mockWith(dataResidencyServer: .US)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithOnlyEUInSourceConfig_DefaultFalse_1() {
        let sourceConfig: SourceConfig = EUDataResidency.defaultFalse
        let config: Config = .mockWith()
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithOnlyEUInSourceConfig_DefaultFalse_2() {
        let sourceConfig: SourceConfig = EUDataResidency.defaultFalse
        let config: Config = .mockWith(dataResidencyServer: .EU)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWithOnlyEUInSourceConfig_DefaultFalse_3() {
        let sourceConfig: SourceConfig = EUDataResidency.defaultFalse
        let config: Config = .mockWith(dataResidencyServer: .US)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWhenNoUrlInSourceConfig_1() {
        let sourceConfig: SourceConfig = .mockWith(
            source: .mockWith(
                dataPlanes: nil
            )
        )
        let config: Config = .mockWith()
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWhenNoUrlInSourceConfig_2() {
        let sourceConfig: SourceConfig = .mockWith(
            source: .mockWith(
                dataPlanes: nil
            )
        )
        let config: Config = .mockWith(dataResidencyServer: .EU)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
    
    func testWhenNoUrlInSourceConfig_3() {
        let sourceConfig: SourceConfig = .mockWith(
            source: .mockWith(
                dataPlanes: nil
            )
        )
        let config: Config = .mockWith(dataResidencyServer: .US)
        let dataResidency = DataResidency(dataResidencyServer: config.dataResidencyServer, sourceConfig: sourceConfig)
        
        XCTAssertNil(dataResidency.dataPlaneUrl)
    }
        
    func testWhenNoUrlInSourceConfig_4() {
        let config: Config? = Config(writeKey: WRITE_KEY, dataPlaneURL: "https::/dataplanerudderstackcom")
        XCTAssertNil(config)
    }
}

class MultiDataResidency {
    static let defaultTrue: SourceConfig = .mockWith(
        source: .mockWith(
            dataPlanes: .mockWith(
                eu: [
                    .mockWith(
                        url: EU,
                        default: true
                    )
                ],
                us: [
                    .mockWith(
                        url: US,
                        default: true
                    )
                ]
            )
        )
    )
    
    static let defaultFalse: SourceConfig = .mockWith(
        source: .mockWith(
            dataPlanes: .mockWith(
                eu: [
                    .mockWith(
                        url: EU,
                        default: false
                    )
                ],
                us: [
                    .mockWith(
                        url: US,
                        default: false
                    )
                ]
            )
        )
    )
    
    static let USTrue: SourceConfig = .mockWith(
        source: .mockWith(
            dataPlanes: .mockWith(
                eu: [
                    .mockWith(
                        url: EU,
                        default: false
                    )
                ],
                us: [
                    .mockWith(
                        url: US,
                        default: true
                    )
                ]
            )
        )
    )
    
    static let EUTrue: SourceConfig = .mockWith(
        source: .mockWith(
            dataPlanes: .mockWith(
                eu: [
                    .mockWith(
                        url: EU,
                        default: true
                    )
                ],
                us: [
                    .mockWith(
                        url: US,
                        default: false
                    )
                ]
            )
        )
    )
}

class USDataResidency {
    static let defaultTrue: SourceConfig = .mockWith(
        source: .mockWith(
            dataPlanes: .mockWith(
                eu: nil,
                us: [
                    .mockWith(
                        url: US,
                        default: true
                    )
                ]
            )
        )
    )
    
    static let defaultFalse: SourceConfig = .mockWith(
        source: .mockWith(
            dataPlanes: .mockWith(
                eu: nil,
                us: [
                    .mockWith(
                        url: US,
                        default: false
                    )
                ]
            )
        )
    )
}

class EUDataResidency {
    static let defaultTrue: SourceConfig = .mockWith(
        source: .mockWith(
            dataPlanes: .mockWith(
                eu: [
                    .mockWith(
                        url: EU,
                        default: true
                    )
                ],
                us: nil
            )
        )
    )
    
    static let defaultFalse: SourceConfig = .mockWith(
        source: .mockWith(
            dataPlanes: .mockWith(
                eu: [
                    .mockWith(
                        url: EU,
                        default: false
                    )
                ],
                us: nil
            )
        )
    )
}
