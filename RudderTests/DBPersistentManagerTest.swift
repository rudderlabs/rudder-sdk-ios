//
//  RudderTests.swift
//  RudderTests
//
//  Created by Desu Sai Venkat on 31/05/22.
//

import XCTest
@testable import Rudder

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
    let DESTINATION_ID_1 = "1wZzqrP8pG55s2GSN0pAzEiatBL"
    let DESTINATION_ID_2 = "1wZzqrP8pG55s2GSN0pAsadiesh"
    
    let ROWID_1 = 1 as NSNumber
    let ROWID_2 = 2 as NSNumber
    let ROWID_3 = 3 as NSNumber
    
    override func setUpWithError() throws {
        dbPersistentManager = RSDBPersistentManager()
        deleteEventsTable()
        deleteEventsToDestinationIdMappingTable()
    }
    
    override func tearDownWithError() throws {
        deleteEventsTable()
        deleteEventsToDestinationIdMappingTable()
    }
    
    func testMigration() throws {
        // creating events table with version 1 i.e prior to migration
        dbPersistentManager.createEventsTable(withVersion:1)
        // inserting message1 into the table prior to migration
        dbPersistentManager.saveEvent(MESSAGE_1)
        // inserting message2 into the table prior to migration
        dbPersistentManager.saveEvent(MESSAGE_2)
        // checking if both the messages got saved to the db successfully prior to migration
        XCTAssert(dbPersistentManager.fetchAllEventsFromDB(forMode: ALL).messageIds.count==2)
        // verifying that the status column is missing from the events table
        XCTAssert(!dbPersistentManager.checkIfStatusColumnExists())
        dbPersistentManager.performMigration()
        // verifying if the status column exists in the event table after migration
        XCTAssert(dbPersistentManager.checkIfStatusColumnExists())
        // verifying if both the messages exist in the table even after migration
        let rsDbMessage: RSDBMessage = dbPersistentManager.fetchAllEventsFromDB(forMode: ALL)
        print(rsDbMessage.statuses)
        XCTAssert(rsDbMessage.messageIds.count==2)
        XCTAssert(rsDbMessage.statuses[0] as? Int == 1)
        XCTAssert(rsDbMessage.statuses[1] as? Int == 1)
    }
    
    func testCreateEventsTableWithVersion () throws {
        dbPersistentManager.createEventsTable(withVersion: 2)
        XCTAssert(getCount(sqlString: getCheckIfTableExistCommand(tableName: "events")) > 0)
        XCTAssert(dbPersistentManager.checkIfStatusColumnExists() == true)
        deleteEventsTable()
        XCTAssert(getCount(sqlString: getCheckIfTableExistCommand(tableName: "events")) == 0)
        dbPersistentManager.createEventsTable(withVersion: 1)
        XCTAssert(getCount(sqlString: getCheckIfTableExistCommand(tableName: "events")) > 0)
        XCTAssert(dbPersistentManager.checkIfStatusColumnExists() == false)
    }
    
    func testSaveEvent() throws {
        dbPersistentManager.createEventsTable(withVersion: 2)
        let rowId1: Int = dbPersistentManager.saveEvent(MESSAGE_1).intValue
        let rowId2: Int = dbPersistentManager.saveEvent(MESSAGE_2).intValue
        let rsDbMessage = dbPersistentManager.fetchAllEventsFromDB(forMode: ALL)
        XCTAssert(rsDbMessage.messageIds.count == 2)
        XCTAssert((rsDbMessage.messageIds[0] as! NSString).integerValue == rowId1)
        XCTAssert((rsDbMessage.messageIds[1] as! NSString).integerValue == rowId2)
    }
    
    func testClearEventsFromDB() throws {
        var rowIds : [String] = []
        dbPersistentManager.createEventsTable(withVersion: 2)
        for _ in 1...20 {
            rowIds.append(dbPersistentManager.saveEvent(MESSAGE_1).stringValue)
        }
        rowIds.sort()
        let dbMessage:RSDBMessage = dbPersistentManager.fetchAllEventsFromDB(forMode: ALL)
        var savedRowIds:Array<String> = dbMessage.messageIds as! Array<String>
        savedRowIds.sort()
        XCTAssert(rowIds == savedRowIds)
    }
    
    func testCreateEventsToDestinationIdMappingTable() throws {
        dbPersistentManager.createEventsToDestinationIdMappingTable();
        XCTAssert(getCount(sqlString: getCheckIfTableExistCommand(tableName: "events_to_destination")) > 0)
    }
    
    func testFetchEventsFromDB() {
        dbPersistentManager.createEventsTable(withVersion: 2)
        var rowIds:[Int] = []
        for _ in 1...70 {
            rowIds.append(dbPersistentManager.saveEvent(MESSAGE_1).intValue)
        }
        
        var device_mode_rowIds : [String] = []
        var cloud_mode_rowIds : [String] = []
        for (index, rowId) in rowIds.enumerated() {
            if(index % 2 == 0) {
                device_mode_rowIds.append(String(rowId))
                continue;
            }
            cloud_mode_rowIds.append(String(rowId))
        }
        
        
        // test updateEventsWithIds
        dbPersistentManager.updateEvents(withIds: NSMutableArray(array:device_mode_rowIds), with: CLOUDMODEPROCESSINGDONE)
        dbPersistentManager.updateEvents(withIds: NSMutableArray(array:cloud_mode_rowIds), with: DEVICEMODEPROCESSINGDONE)
        let fetched_device_mode_ids : [String] = dbPersistentManager.fetchAllEventsFromDB(forMode: DEVICEMODE).messageIds as NSArray as! [String]
        let fetched_cloud_mode_ids : [String] = dbPersistentManager.fetchAllEventsFromDB(forMode: CLOUDMODE).messageIds as NSArray as! [String]
        XCTAssertTrue(fetched_cloud_mode_ids.allSatisfy(cloud_mode_rowIds.contains))
        XCTAssertTrue(fetched_device_mode_ids.allSatisfy(device_mode_rowIds.contains))
        
        // test getDBRecordCount For Mode
        XCTAssertEqual(dbPersistentManager.getDBRecordCount(forMode: ALL), 70)
        XCTAssertEqual(dbPersistentManager.getDBRecordCount(forMode: CLOUDMODE), 35)
        XCTAssertEqual(dbPersistentManager.getDBRecordCount(forMode: DEVICEMODE), 35)
     
        // test fetchAllEventsFromDB
        XCTAssertEqual(dbPersistentManager.fetchAllEventsFromDB(forMode: ALL).messageIds.count, 70)
        XCTAssertEqual(dbPersistentManager.fetchAllEventsFromDB(forMode: CLOUDMODE).messageIds.count, 35)
        XCTAssertEqual(dbPersistentManager.fetchAllEventsFromDB(forMode: DEVICEMODE).messageIds.count, 35)
        
        // test fetchEventsFromDB
        XCTAssertEqual(dbPersistentManager.fetchEvents(fromDB: 37, forMode: CLOUDMODE).messageIds.count, 35)
        XCTAssertEqual(dbPersistentManager.fetchEvents(fromDB: 72, forMode: DEVICEMODE).messageIds.count, 35)
        XCTAssertEqual(dbPersistentManager.fetchEvents(fromDB: 250, forMode: ALL).messageIds.count, 70)
        
        
    }
    
    func testClearProcessedEventsFromDB() throws {
        dbPersistentManager.createEventsTable(withVersion: 2)
        var rowIds:[String] = []
        for _ in 1...20 {
            rowIds.append(dbPersistentManager.saveEvent(MESSAGE_1).stringValue)
        }
        XCTAssertEqual(dbPersistentManager.fetchAllEventsFromDB(forMode: ALL).messageIds.count , 20)
        
        dbPersistentManager.updateEvents(withIds: NSMutableArray(array:Array(rowIds[0...9])), with:COMPLETEPROCESSINGDONE)
        dbPersistentManager.clearProcessedEventsFromDB()
        XCTAssertEqual(dbPersistentManager.fetchAllEventsFromDB(forMode: ALL).messageIds.count , 10)
        dbPersistentManager.updateEvents(withIds: NSMutableArray(array: Array(rowIds[10...19])), with: COMPLETEPROCESSINGDONE)
        dbPersistentManager.clearProcessedEventsFromDB()
        XCTAssertEqual(dbPersistentManager.fetchAllEventsFromDB(forMode: ALL).messageIds.count , 0)
        
    }
    
    func testFlushEventsFromDB() throws {
        dbPersistentManager.createEventsTable(withVersion: 2)
        for _ in 1...20 {
            dbPersistentManager.saveEvent(MESSAGE_1)
        }
        dbPersistentManager.flushEventsFromDB()
        XCTAssertEqual(dbPersistentManager.fetchAllEventsFromDB(forMode: ALL).messageIds.count, 0)
    }
    
    func testSaveEventWithDestinationId() throws {
        dbPersistentManager.createEventsTable(withVersion: 2)
        dbPersistentManager.createEventsToDestinationIdMappingTable()
        let rowId1: Int = dbPersistentManager.saveEvent(MESSAGE_1).intValue
        let rowId2: Int = dbPersistentManager.saveEvent(MESSAGE_2).intValue
        dbPersistentManager.saveEvent(rowId1 as NSNumber, toDestinationId: DESTINATION_ID_1)
        dbPersistentManager.saveEvent(rowId2 as NSNumber, toDestinationId: DESTINATION_ID_2)
        let eventsToDestinationMapping: [String:Any] = dbPersistentManager.getDestinationMappingofEvents([String(rowId1),String(rowId2)])
        var eventIdsArray = Array(eventsToDestinationMapping.keys)
        eventIdsArray.sort()
        XCTAssertEqual(Int(eventIdsArray[0]), rowId1)
        XCTAssertEqual(Int(eventIdsArray[1]), rowId2)
    }
    
    func testDeleteEventWithDestinationId() throws {
        dbPersistentManager.createEventsToDestinationIdMappingTable()
        dbPersistentManager.saveEvent(ROWID_1, toDestinationId: DESTINATION_ID_1)
        dbPersistentManager.saveEvent(ROWID_1, toDestinationId: DESTINATION_ID_2)
        dbPersistentManager.saveEvent(ROWID_2, toDestinationId: DESTINATION_ID_1)
        dbPersistentManager.saveEvent(ROWID_2, toDestinationId: DESTINATION_ID_2)
    
        var destinationsOfEvent = dbPersistentManager.getDestinationMappingofEvents([ROWID_1.stringValue])
        XCTAssertTrue([DESTINATION_ID_1, DESTINATION_ID_2].allSatisfy(destinationsOfEvent[ROWID_1.stringValue]!.contains))
        
        dbPersistentManager.deleteEvents([ROWID_1.stringValue], withDestinationId: DESTINATION_ID_1)
        destinationsOfEvent = dbPersistentManager.getDestinationMappingofEvents([ROWID_1.stringValue])
        XCTAssertFalse([DESTINATION_ID_1, DESTINATION_ID_2].allSatisfy(destinationsOfEvent[ROWID_1.stringValue]!.contains))
    }
    
    func testgetEventIdsWithDestinationMapping() throws {
        dbPersistentManager.createEventsToDestinationIdMappingTable()
        dbPersistentManager.saveEvent(ROWID_1, toDestinationId: DESTINATION_ID_1)
        dbPersistentManager.saveEvent(ROWID_1, toDestinationId: DESTINATION_ID_2)
        dbPersistentManager.saveEvent(ROWID_2, toDestinationId: DESTINATION_ID_1)
        dbPersistentManager.saveEvent(ROWID_2, toDestinationId: DESTINATION_ID_2)
        let destinationMappingOfEvents = dbPersistentManager.getDestinationMappingofEvents([ROWID_1.stringValue, ROWID_2.stringValue, ROWID_3.stringValue])
        XCTAssertTrue(destinationMappingOfEvents.keys.contains(ROWID_2.stringValue))
        XCTAssertFalse(destinationMappingOfEvents.keys.contains(ROWID_3.stringValue))
        
    }
    
    func deleteEventsTable() {
        executeSQL(sqlString: "drop table if exists events;")
    }
    
    func deleteEventsToDestinationIdMappingTable() {
        executeSQL(sqlString: "drop table if exists events_to_destination;")
    }
    
    func getCheckIfTableExistCommand(tableName: String) -> String {
        return "SELECT count(name) FROM sqlite_master WHERE type='table' AND name='\(tableName)';"
    }
    
    func executeSQL(sqlString: String) {
        var db: OpaquePointer?
        if sqlite3_open(RSUtils.getDBPath(), &db) == SQLITE_OK {
            var sqlStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, sqlString, -1, &sqlStatement, nil) ==
                SQLITE_OK {
                if sqlite3_step(sqlStatement) == SQLITE_DONE {
                    print("\n executeSQL: Successfully executed the SQL Statement.")
                } else {
                    print("\n executeSQL: Failed to execute the SQL Statement.")
                }
            } else {
                print("\n executeSQL: Failed to prepare the SQL Statement")
            }
            sqlite3_finalize(sqlStatement)
        }
    }
    
    func getCount(sqlString: String) -> Int {
        var count:Int = -1
        var db: OpaquePointer?
        if sqlite3_open(RSUtils.getDBPath(), &db) == SQLITE_OK {
            var sqlStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, sqlString, -1, &sqlStatement, nil) ==
                SQLITE_OK {
                if sqlite3_step(sqlStatement) == SQLITE_ROW {
                    count = Int(sqlite3_column_int(sqlStatement, 0))
                    if(count > 0) {
                        print("\n getCount: Successfully retrieved the count.")
                    }
                } else {
                    print("\n getCount: Failed to retrieve the count.")
                }
            } else {
                print("\n getCount: Failed to prepare the SQL Statement.")
            }
            sqlite3_finalize(sqlStatement)
        }
        return count;
    }
    
}
