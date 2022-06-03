//
//  RudderTests.swift
//  RudderTests
//
//  Created by Desu Sai Venkat on 31/05/22.
//

import XCTest
import Rudder

class DBPersistentManagerTest: XCTestCase {
    
    var dbPersistentManager: RSDBPersistentManager!
    let MESSAGE_1 = """
    {
    "event": "mess-1",
    "messageId": "e-1",
    "message": "m-1",
    "sentAt": "2022-03-14T06:46:41.365Z"
    }
"""
    
    let MESSAGE_2 = """
    {
    "event": "mess-2",
    "messageId": "e-2",
    "message": "m-2",
    "sentAt": "2022-03-14T06:46:41.365Z"
    }
"""
    let TRANSFORMATION_ID_1 = "1wZzqrP8pG55s2GSN0pAzEiatBL"
    let TRANSFORMATION_ID_2 = "1wZzqrP8pG55s2GSN0pAsadiesh"
    
    override func setUpWithError() throws {
        dbPersistentManager = RSDBPersistentManager()
        deleteEventsTable()
    }
    
    override func tearDownWithError() throws {
        deleteEventsTable()
    }
    
    func testMigration() throws {
        // creating events table with version 1 i.e prior to migration
        dbPersistentManager.createEventsTablewithVersion(1)
        // inserting message1 into the table prior to migration
        dbPersistentManager.saveEvent(MESSAGE_1)
        // inserting message2 into the table prior to migration
        dbPersistentManager.saveEvent(MESSAGE_2)
        // checking if both the messages got saved to the db successfully prior to migration
        XCTAssert(dbPersistentManager.fetchAllEventsFromDB().messageIds.count==2)
        // verifying that the status column is missing from the events table
        XCTAssert(!dbPersistentManager.checkIfStatusColumnExists())
        dbPersistentManager.performMigration()
        // verifying if the status column exists in the event table after migration
        XCTAssert(dbPersistentManager.checkIfStatusColumnExists())
        // verifying if both the messages exist in the table even after migration
        let rsDbMessage: RSDBMessage = dbPersistentManager.fetchAllEventsFromDB()
        print(rsDbMessage.statuses)
        XCTAssert(rsDbMessage.messageIds.count==2)
        XCTAssert(rsDbMessage.statuses[0] as? Int == 1)
        XCTAssert(rsDbMessage.statuses[1] as? Int == 1)
    }
    
    func testSaveEvent() throws {
        dbPersistentManager.createEventsTablewithVersion(2)
        let rowId1: Int = dbPersistentManager.saveEvent(MESSAGE_1).intValue
        let rowId2: Int = dbPersistentManager.saveEvent(MESSAGE_2).intValue
        let rsDbMessage = dbPersistentManager.fetchAllEventsFromDB()
        XCTAssert(rsDbMessage.messageIds.count == 2)
        XCTAssert((rsDbMessage.messageIds[0] as! NSString).integerValue == rowId1)
        XCTAssert((rsDbMessage.messageIds[1] as! NSString).integerValue == rowId2)
    }
    
    func testSaveEventWithTransformationId() throws {
        dbPersistentManager.createEventsTablewithVersion(2)
        dbPersistentManager.createEventsToTransformationMappingTable()
        let rowId1: Int = dbPersistentManager.saveEvent(MESSAGE_1).intValue
        let rowId2: Int = dbPersistentManager.saveEvent(MESSAGE_2).intValue
        dbPersistentManager.saveEvent(rowId1 as NSNumber, toTransformationId: TRANSFORMATION_ID_1)
        dbPersistentManager.saveEvent(rowId2 as NSNumber, toTransformationId: TRANSFORMATION_ID_2)
        let eventsToTransformationMapping: [NSNumber:String] = dbPersistentManager.getEventsToTransformationMapping()
        let eventIdsArray = Array(eventsToTransformationMapping.keys)
        XCTAssert(eventIdsArray[0].intValue == rowId1)
        XCTAssert(eventIdsArray[1].intValue == rowId2)
    }

    
    func deleteEventsTable() {
        executeSQL(sqlString: "drop table if exists events;")
    }
    
    func executeSQL(sqlString: String) {
        var db: OpaquePointer?
        if sqlite3_open(RSUtils.getDBPath(), &db) == SQLITE_OK {
            var sqlStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, sqlString, -1, &sqlStatement, nil) ==
                SQLITE_OK {
                if sqlite3_step(sqlStatement) == SQLITE_DONE {
                    print("\nEvents table is deleted.")
                } else {
                    print("\nEvents table failed to be deleted.")
                }
            } else {
                print("\nDelete TABLE statement is not prepared.")
            }
            sqlite3_finalize(sqlStatement)
        }
    }
    
}
