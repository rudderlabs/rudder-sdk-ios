//
//  RudderUtilsTest.swift
//  RudderTests
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
        
        let response:Any = RSUtils.deSerializeJSONString(jsonString)
        let parsedDict:[String:String]? = response as? [String:String] ?? nil
        XCTAssert(parsedDict == dictObj)
        
        
    }
}
