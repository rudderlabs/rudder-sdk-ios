//
//  RudderUtilsTest.swift
//  Tests
//
//  Created by Desu Sai Venkat on 14/07/22.
//

import Foundation
import XCTest
import Rudder

class RudderUtilsTest: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
    }
    
    func testGetCSVString() throws {
        let bio:[String] = ["Desu","Mobile Engineer", "RudderStack"]
        let bioCSV = RSUtils.getCSVString(bio)
        print(bioCSV)
        XCTAssert(bioCSV == "Desu,Mobile Engineer,RudderStack")
        let carriers:[String] = ["Airtel"]
        let carriersCSV = RSUtils.getCSVString(carriers)
        print(carriersCSV)
        XCTAssertEqual(carriersCSV, "Airtel")
        
    }
    
    func testGetJSONCSVString() throws {
        let bio:[String] = ["Desu","Mobile Engineer", "RudderStack"]
        let bioJSONCSV = RSUtils.getJSONCSVString(bio)
        print(bioJSONCSV == "\"Desu\",\"Mobile Engineer\",\"RudderStack\"")
    }
    
    func testGetBatch() throws {
        let numsArr = Array(0...30)
        let inputArr = NSMutableArray(array: numsArr)
        let  outputArr = RSUtils.getBatch(inputArr, withQueueSize: 10)
        XCTAssert(outputArr.count == 10)
    }
    
    func testGetNumberOfBatches() throws {
        let dbMessage = RSDBMessage()
        dbMessage.messageIds = NSMutableArray(array:Array(0...116))
        dbMessage.messages = NSMutableArray(array:Array(0...116))
        let numberOfBatches: Int = Int(RSUtils.getNumberOfBatches(dbMessage, withFlushQueueSize: 30))
        XCTAssert( numberOfBatches == 4 )
    }
    
    func testDeserializeJsonString() throws {
        let jsonString =
"""
{
"name" : "Desu Sai Venkat",
"company" : "RudderStack",
"city" : "Hyderabad"
}
"""
        let dictObj : [String:String] = [
            "name" : "Desu Sai Venkat",
            "company" : "RudderStack",
            "city" : "Hyderabad"]
        
        let response = RSUtils.deSerializeJSONString(jsonString)
        let parsedDict:[String:String]? = response as? [String:String] ?? nil
        XCTAssert(parsedDict == dictObj)
        
        
    }
    
    func testSortArray() throws {
        let numsArr = [3,2,12,6,5]
        XCTAssertEqual(RSUtils.sortArray(NSMutableArray(array:numsArr), in: ASCENDING), NSMutableArray(array:[2,3,5,6,12]))
        XCTAssertEqual(RSUtils.sortArray(NSMutableArray(array:numsArr), in: DESCENDING), NSMutableArray(array:[12,6,5,3,2]))
    }
}
