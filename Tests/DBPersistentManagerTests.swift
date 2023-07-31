//
//  DBPersistentManagerTests.swift
//  Tests
//
//  Created by Desu Sai Venkat on 31/05/22.
//

import XCTest
@testable import Rudder

class DBPersistentManagerTests: XCTestCase {
    
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
    
    
    let MESSAGE_3 = """
    {
    "event": "mess-3",
    "messageId": "e-3",
    "message": "m-3",
    "sentAt": "2022-03-14T06:46:41.365Z"
    }
"""
    
    let ROWID_1 = 1 as NSNumber
    let ROWID_2 = 2 as NSNumber
    let ROWID_3 = 3 as NSNumber
    
    let COL_STATUS = "status";
    let COL_DM_PROCESSED = "dm_processed";
    
    override func setUpWithError() throws {
        dbPersistentManager = RSDBPersistentManager()
        deleteEventsTable()
        deleteEventsToDestinationIdMappingTable()
    }
    
    override func tearDownWithError() throws {
        deleteEventsTable()
        deleteEventsToDestinationIdMappingTable()
    }
    
    func testMigrationFromV1ToV2() throws {
        // creating events table with version 1 i.e prior to migration
        dbPersistentManager.createEventsTable(withVersion:1)
        // inserting message1 into the table prior to migration
        dbPersistentManager.saveEvent(MESSAGE_1)
        // inserting message2 into the table prior to migration
        dbPersistentManager.saveEvent(MESSAGE_2)
        // checking if both the messages got saved to the db successfully prior to migration
        XCTAssert(dbPersistentManager.fetchAllEventsFromDB(forMode: ALL).messageIds.count==2)
        // verifying that the status column is missing from the events table
        XCTAssert(!dbPersistentManager.checkIfColumnExists(COL_STATUS))
        dbPersistentManager.performMigration(COL_STATUS)
        // inserting message3 into the table after the migration
        dbPersistentManager.saveEvent(MESSAGE_3)
        // verifying if the status column exists in the event table after migration
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_STATUS))
        // verifying if both the messages exist in the table even after migration
        let rsDbMessage: RSDBMessage = dbPersistentManager.fetchAllEventsFromDB(forMode: ALL)
        XCTAssert(rsDbMessage.messageIds.count==3)
        XCTAssert(rsDbMessage.statusList[0] as? Int == 1)
        XCTAssert(rsDbMessage.statusList[1] as? Int == 1)
        XCTAssert(rsDbMessage.statusList[2] as? Int == 0)
    }
    
    func testMigrationFromV1ToV3() throws {
        // creating events table with version 1 i.e prior to migration
        dbPersistentManager.createEventsTable(withVersion:1)
        // inserting message1 into the table prior to migration
        dbPersistentManager.saveEvent(MESSAGE_1)
        // inserting message2 into the table prior to migration
        dbPersistentManager.saveEvent(MESSAGE_2)
        // checking if both the messages got saved to the db successfully prior to migration
        XCTAssert(dbPersistentManager.fetchAllEventsFromDB(forMode: ALL).messageIds.count==2)
        // verifying that the status column is missing from the events table
        XCTAssert(!dbPersistentManager.checkIfColumnExists(COL_STATUS))
        dbPersistentManager.performMigration(COL_STATUS)
        // verifying that the dm_processed column is missing from the events table
        XCTAssert(!dbPersistentManager.checkIfColumnExists(COL_DM_PROCESSED))
        dbPersistentManager.performMigration(COL_DM_PROCESSED)
        // inserting message3 into the table after the migration
        dbPersistentManager.saveEvent(MESSAGE_3)
        // verifying if the status column exists in the event table after migration
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_STATUS))
        // verifying if the dm_processed column exists in the event table after migration
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_DM_PROCESSED))
        // verifying if events made prior to migration their status is marked as DEVICE_MODE_PROCESSING_DONE. For new messages it should be 0
        let rsDbMessage: RSDBMessage = dbPersistentManager.fetchAllEventsFromDB(forMode: ALL)
        XCTAssert(rsDbMessage.messageIds.count==3)
        XCTAssert(rsDbMessage.statusList[0] as? Int == 1)
        XCTAssert(rsDbMessage.statusList[1] as? Int == 1)
        XCTAssert(rsDbMessage.statusList[2] as? Int == 0)
        // verifying if events made prior to migration their dm_processed is marked as DM_PROCESSED_DONE. For new messages it should be 0
        XCTAssert(rsDbMessage.dmProcessed[0] as? Int == 1)
        XCTAssert(rsDbMessage.dmProcessed[1] as? Int == 1)
        XCTAssert(rsDbMessage.dmProcessed[2] as? Int == 0)
    }
    
    func testMigrationFromV2ToV3() throws {
        // creating events table with version 2 i.e prior to migration
        dbPersistentManager.createEventsTable(withVersion:2)
        // inserting message1 into the table prior to migration
        dbPersistentManager.saveEvent(MESSAGE_1)
        // inserting message2 into the table prior to migration
        dbPersistentManager.saveEvent(MESSAGE_2)
        // checking if both the messages got saved to the db successfully prior to migration
        XCTAssert(dbPersistentManager.fetchAllEventsFromDB(forMode: ALL).messageIds.count==2)
        // verifying that the status column exist in the events table
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_STATUS))
        // verifying that the dm_processed column is missing from the events table
        XCTAssert(!dbPersistentManager.checkIfColumnExists(COL_DM_PROCESSED))
        dbPersistentManager.performMigration(COL_DM_PROCESSED)
        // inserting message3 into the table after the migration
        dbPersistentManager.saveEvent(MESSAGE_3)
        // verifying if the dm_processed column exists in the event table after migration
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_DM_PROCESSED))
        // verifying if events made prior to migration, status is marked as DEVICE_MODE_PROCESSING_DONE. For new messages it should be 0
        let rsDbMessage: RSDBMessage = dbPersistentManager.fetchAllEventsFromDB(forMode: ALL)
        XCTAssert(rsDbMessage.messageIds.count==3)
        XCTAssert(rsDbMessage.statusList[0] as? Int == 1)
        XCTAssert(rsDbMessage.statusList[1] as? Int == 1)
        XCTAssert(rsDbMessage.statusList[2] as? Int == 0)
        // verifying if events made prior to migration, dm_processed is marked as DM_PROCESSED_DONE. For new messages it should be 0
        XCTAssert(rsDbMessage.dmProcessed[0] as? Int == 1)
        XCTAssert(rsDbMessage.dmProcessed[1] as? Int == 1)
        XCTAssert(rsDbMessage.dmProcessed[2] as? Int == 0)
    }
    
    func testCreateEventsTableWithVersion () throws {
        dbPersistentManager.createEventsTable(withVersion: 3)
        XCTAssert(getCount(sqlString: getCheckIfTableExistCommand(tableName: "events")) > 0)
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_STATUS) == true)
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_DM_PROCESSED) == true)
        deleteEventsTable()
        dbPersistentManager.createEventsTable(withVersion: 2)
        XCTAssert(getCount(sqlString: getCheckIfTableExistCommand(tableName: "events")) > 0)
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_STATUS) == true)
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_DM_PROCESSED) == false)
        deleteEventsTable()
        XCTAssert(getCount(sqlString: getCheckIfTableExistCommand(tableName: "events")) == 0)
        dbPersistentManager.createEventsTable(withVersion: 1)
        XCTAssert(getCount(sqlString: getCheckIfTableExistCommand(tableName: "events")) > 0)
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_STATUS) == false)
        XCTAssert(dbPersistentManager.checkIfColumnExists(COL_DM_PROCESSED) == false)
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
        dbPersistentManager.updateEvents(withIds: device_mode_rowIds, with: CLOUD_MODE_PROCESSING_DONE)
        dbPersistentManager.updateEvents(withIds: cloud_mode_rowIds, with: DEVICE_MODE_PROCESSING_DONE)
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
        
        dbPersistentManager.updateEvents(withIds: Array(rowIds[0...9]), with:COMPLETE_PROCESSING_DONE)
        dbPersistentManager.clearProcessedEventsFromDB()
        XCTAssertEqual(dbPersistentManager.fetchAllEventsFromDB(forMode: ALL).messageIds.count , 10)
        dbPersistentManager.updateEvents(withIds: Array(rowIds[10...19]), with: COMPLETE_PROCESSING_DONE)
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
    
    func testMarkDeviceModeTransformationAndProcessedDone() throws {
        dbPersistentManager.createEventsTable(withVersion: 3)
        for _ in 1...3 {
            dbPersistentManager.saveEvent(MESSAGE_1)
        }
        for i in 1...3 {
            dbPersistentManager.markDeviceModeTransformationAndProcessedDone(i as NSNumber)
        }
        // verifying if status is marked as DEVICE_MODE_PROCESSING_DONE or not
        let rsDbMessage: RSDBMessage = dbPersistentManager.fetchAllEventsFromDB(forMode: ALL)
        XCTAssert(rsDbMessage.messageIds.count==3)
        XCTAssert(rsDbMessage.statusList[0] as? Int == 1)
        XCTAssert(rsDbMessage.statusList[1] as? Int == 1)
        XCTAssert(rsDbMessage.statusList[2] as? Int == 1)
        // verifying if dm_processed is marked as DM_PROCESSED_DONE done or not
        XCTAssert(rsDbMessage.messageIds.count==3)
        XCTAssert(rsDbMessage.dmProcessed[0] as? Int == 1)
        XCTAssert(rsDbMessage.dmProcessed[1] as? Int == 1)
        XCTAssert(rsDbMessage.dmProcessed[2] as? Int == 1)
    }
    
    func testMarkDeviceModeProcessedDone() throws {
        dbPersistentManager.createEventsTable(withVersion: 3)
        for _ in 1...3 {
            dbPersistentManager.saveEvent(MESSAGE_1)
        }
        for i in 1...3 {
            dbPersistentManager.markDeviceModeProcessedDone(i as NSNumber)
        }
        // verifying if status remains 0
        let rsDbMessage: RSDBMessage = dbPersistentManager.fetchAllEventsFromDB(forMode: ALL)
        XCTAssert(rsDbMessage.messageIds.count==3)
        XCTAssert(rsDbMessage.statusList[0] as? Int == 0)
        XCTAssert(rsDbMessage.statusList[1] as? Int == 0)
        XCTAssert(rsDbMessage.statusList[2] as? Int == 0)
        // verifying if dm_processed is marked as DM_PROCESSED_DONE done or not
        XCTAssert(rsDbMessage.messageIds.count==3)
        XCTAssert(rsDbMessage.dmProcessed[0] as? Int == 1)
        XCTAssert(rsDbMessage.dmProcessed[1] as? Int == 1)
        XCTAssert(rsDbMessage.dmProcessed[2] as? Int == 1)
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
