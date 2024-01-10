//
//  DatabaseTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 09/05/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

// swiftlint:disable force_cast
class DatabaseTests: XCTestCase {

    var client: RSClient!
    var databaseManager: RSDatabaseManager!
    
    override func setUpWithError() throws {
//        client = RSClient.sharedInstance()
//        client.configure(with: RSConfig(writeKey: "WRITE_KEY").dataPlaneURL("DATA_PLANE_URL"))
//        databaseManager = RSDatabaseManager(client: client)
    }
    
    override func tearDownWithError() throws {
        client = nil
    }

    /*func testWriteEvent() {
        let trackMessage = TrackMessage(event: "sample_track1", properties: nil)
            .applyRawEventData(userInfo: client.userInfo)
        databaseManager.write(trackMessage)

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        if let allEvents = fetchAllEvents() {
            let event = allEvents[0]["event"] as? String
            XCTAssertTrue(event == "sample_track1")
        } else {
            XCTFail("No events found")
        }
    }
    
    func testRemoveEvent() {
        let trackMessage = TrackMessage(event: "sample_track1", properties: nil)
            .applyRawEventData(userInfo: client.userInfo)
        databaseManager.write(trackMessage)

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        if let allEvents = fetchAllEvents() {
            let event = allEvents[0]["event"] as? String
            XCTAssertTrue(event == "sample_track1")
        } else {
            XCTFail("No events found")
        }
        
        databaseManager.removeEvents([trackMessage.messageId!])
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        if let allEvents = fetchAllEvents() {
            let messageId = allEvents[0]["messageId"] as? String
            XCTAssertFalse(messageId == trackMessage.messageId)
        } else {
            XCTFail("No events found")
        }
    }*/
    
    func fetchAllEvents() -> [[String: Any]]? {
        let totalCount = databaseManager.getDBRecordCount()
        if let dbMessage = databaseManager.getEvents(totalCount) {
            let params = dbMessage.toJSONString()
            if let data = params.data(using: .utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    return json["batch"] as? [[String: Any]]
                } catch {
                    XCTFail("Not a valid JSON")
                }
            } else {
                XCTFail("Could not read from JSON string")
            }
        } else {
            XCTFail("Could not read from database")
        }
        return nil
    }
}
