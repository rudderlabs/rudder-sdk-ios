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
    
    func testGetCSVString() throws {
        let bio:[String] = ["Desu","Mobile Engineer", "RudderStack"]
        let bioCSV = RSUtils.getCSVString(from: bio)
        print(bioCSV)
        XCTAssert(bioCSV == "Desu,Mobile Engineer,RudderStack")
        let carriers:[String] = ["Airtel"]
        let carriersCSV = RSUtils.getCSVString(from: carriers)
        print(carriersCSV)
        XCTAssertEqual(carriersCSV, "Airtel")
        
    }
    
    func testGetJSONCSVString() throws {
        let bio:[String] = ["Desu","Mobile Engineer", "RudderStack"]
        let bioJSONCSV = RSUtils.getCSVString(from: bio)
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
        
        let response = RSUtils.deserialize(jsonString)
        let parsedDict:[String:String]? = response as? [String:String] ?? nil
        XCTAssert(parsedDict == dictObj)
        
        
    }
    
    func testSortArray() throws {
        let numsArr = [3,2,12,6,5]
        XCTAssertEqual(RSUtils.sortArray(NSMutableArray(array:numsArr), in: ASCENDING), NSMutableArray(array:[2,3,5,6,12]))
        XCTAssertEqual(RSUtils.sortArray(NSMutableArray(array:numsArr), in: DESCENDING), NSMutableArray(array:[12,6,5,3,2]))
    }
    
    func testSanitizeDictionary() {
        let dirtyDict: [String:Any] = [
            "infinity": Double.infinity,
            "NaN": Double.nan,
            "negativeInfinity": -Double.infinity,
            "max": Double.greatestFiniteMagnitude,
            "min": Double.leastNormalMagnitude,
            "normal": 1.0,
            "zero": 0.0,
            "negativeNormal": -1.0,
            "general": 35,
            "date": Date(),
            "url": URL(string: "https://www.rudderstack.com")!
        ]
        
        if let cleanDict  = RSUtils.sanitizeObject(dirtyDict) as? [String:Any] {
            XCTAssertTrue(cleanDict["infinity"] is String)
            XCTAssertEqual(cleanDict["infinity"] as? String, "Infinity")
            XCTAssertTrue(cleanDict["negativeInfinity"] is String)
            XCTAssertEqual(cleanDict["negativeInfinity"] as? String, "-Infinity")
            XCTAssertTrue(cleanDict["NaN"] is String)
            XCTAssertEqual(cleanDict["NaN"] as? String, "NaN")
            XCTAssertTrue(cleanDict["date"] is String)
            XCTAssertTrue(cleanDict["url"] is String)
            XCTAssertEqual(cleanDict["url"] as? String, "https://www.rudderstack.com")
            XCTAssertTrue(cleanDict["max"] is Double)
            XCTAssertEqual(cleanDict["max"] as? Double, Double.greatestFiniteMagnitude)
            XCTAssertTrue(cleanDict["min"] is Double)
            XCTAssertEqual(cleanDict["min"] as? Double, Double.leastNormalMagnitude)
            XCTAssertTrue(cleanDict["normal"] is Double)
            XCTAssertEqual(cleanDict["normal"] as? Double, 1.0)
            XCTAssertTrue(cleanDict["zero"] is Double)
            XCTAssertEqual(cleanDict["zero"] as? Double, 0.0)
            XCTAssertTrue(cleanDict["negativeNormal"] is Double)
            XCTAssertEqual(cleanDict["negativeNormal"] as? Double, -1.0)
            XCTAssertTrue(cleanDict["general"] is Int)
            XCTAssertEqual(cleanDict["general"] as? Int, 35)
        } else {
            XCTFail("Clean Dict shouldn't be nil")
        }
    }
    
    func testSanitizeArray() {
        let dirtyArray: [Any] = [
            Double.infinity,
            Double.nan,
            -Double.infinity,
            Double.greatestFiniteMagnitude,
            Double.leastNormalMagnitude,
            1.0,
            0.0,
            -1.0,
            35,
            Date(),
            URL(string: "https://www.rudderstack.com")!
        ]
        
        if let cleanArray  = RSUtils.sanitizeObject(dirtyArray) as? [Any] {
            XCTAssertTrue(cleanArray[0] is String)
            XCTAssertEqual(cleanArray[0] as? String, "Infinity")
            XCTAssertTrue(cleanArray[1] is String)
            XCTAssertEqual(cleanArray[1] as? String, "NaN")
            XCTAssertTrue(cleanArray[2] is String)
            XCTAssertEqual(cleanArray[2] as? String, "-Infinity")
            XCTAssertTrue(cleanArray[3] is Double)
            XCTAssertEqual(cleanArray[3] as? Double, Double.greatestFiniteMagnitude)
            XCTAssertTrue(cleanArray[4] is Double)
            XCTAssertEqual(cleanArray[4] as? Double, Double.leastNormalMagnitude)
            XCTAssertTrue(cleanArray[5] is Double)
            XCTAssertEqual(cleanArray[5] as? Double, 1.0)
            XCTAssertTrue(cleanArray[6] is Double)
            XCTAssertEqual(cleanArray[6] as? Double, 0.0)
            XCTAssertTrue(cleanArray[7] is Double)
            XCTAssertEqual(cleanArray[7] as? Double, -1.0)
            XCTAssertTrue(cleanArray[8] is Int)
            XCTAssertEqual(cleanArray[8] as? Int, 35)
            XCTAssertTrue(cleanArray[9] is String)
            XCTAssertTrue(cleanArray[10] is String)
            XCTAssertEqual(cleanArray[10] as? String, "https://www.rudderstack.com")
        } else {
            XCTFail("Clean Array shouldn't be nil")
        }
    }
    
    func testSanitizeNestedDictionary() {
        let dirtyDict: [String:Any] = [
            "date": Date(),
            "url": URL(string: "https://www.rudderstack.com")!,
            "nestedDict": [
                "infinity": Double.infinity,
                "NaN": Double.nan,
                "negativeInfinity": -Double.infinity,
                "max": Double.greatestFiniteMagnitude,
            ],
            "nestedArray": [
                Double.infinity,
                Double.nan,
                Double.greatestFiniteMagnitude,
                [
                    "date": Date(),
                    "url": URL(string: "https://www.rudderstack.com")!,
                ]
            ]
        ]
        
        if let cleanDict  = RSUtils.sanitizeObject(dirtyDict) as? [String:Any] {
            XCTAssertTrue(cleanDict["date"] is String)
            XCTAssertTrue(cleanDict["url"] is String)
            XCTAssertEqual(cleanDict["url"] as? String, "https://www.rudderstack.com")
            XCTAssertTrue(cleanDict["nestedDict"] is [String:Any])
            if let nestedDict = cleanDict["nestedDict"] as? [String:Any] {
                XCTAssertTrue(nestedDict["infinity"] is String)
                XCTAssertEqual(nestedDict["infinity"] as? String, "Infinity")
                XCTAssertTrue(nestedDict["negativeInfinity"] is String)
                XCTAssertEqual(nestedDict["negativeInfinity"] as? String, "-Infinity")
                XCTAssertTrue(nestedDict["NaN"] is String)
                XCTAssertEqual(nestedDict["NaN"] as? String, "NaN")
                XCTAssertTrue(nestedDict["max"] is Double)
                XCTAssertEqual(nestedDict["max"] as? Double, Double.greatestFiniteMagnitude)
            } else {
                XCTFail("Nested Dict shouldn't be nil")
            }
            XCTAssertTrue(cleanDict["nestedArray"] is [Any])
            if let nestedArray = cleanDict["nestedArray"] as? [Any] {
                XCTAssertTrue(nestedArray[0] is String)
                XCTAssertEqual(nestedArray[0] as? String, "Infinity")
                XCTAssertTrue(nestedArray[1] is String)
                XCTAssertEqual(nestedArray[1] as? String, "NaN")
                XCTAssertTrue(nestedArray[2] is Double)
                XCTAssertEqual(nestedArray[2] as? Double, Double.greatestFiniteMagnitude)
                XCTAssertTrue(nestedArray[3] is [String:Any])
                if let nestedDict = nestedArray[3] as? [String:Any] {
                    XCTAssertTrue(nestedDict["date"] is String)
                    XCTAssertTrue(nestedDict["url"] is String)
                    XCTAssertEqual(nestedDict["url"] as? String, "https://www.rudderstack.com")
                } else {
                    XCTFail("Nested Dict shouldn't be nil")
                }
            } else {
                XCTFail("Nested Array shouldn't be nil")
            }
        }
    }

    func testSanitizeNestedArray() {
        let dirtyArray: [Any] = [
            Double.infinity,
            Double.nan,
            -Double.infinity,
            Double.greatestFiniteMagnitude,
            Double.leastNormalMagnitude,
            1.0,
            0.0,
            -1.0,
            35,
            Date(),
            URL(string: "https://www.rudderstack.com")!,
            [
                "date": Date(),
                "url": URL(string: "https://www.rudderstack.com")!,
                "nestedDict": [
                    "infinity": Double.infinity,
                    "NaN": Double.nan,
                    "negativeInfinity": -Double.infinity,
                    "max": Double.greatestFiniteMagnitude,
                ],
                "nestedArray": [
                    Double.infinity,
                    Double.nan,
                    Double.greatestFiniteMagnitude,
                    [
                        "date": Date(),
                        "url": URL(string: "https://www.rudderstack.com")!,
                    ]
                ]
            ]
        ]
        
        if let cleanArray  = RSUtils.sanitizeObject(dirtyArray) as? [Any] {
            XCTAssertTrue(cleanArray[0] is String)
            XCTAssertEqual(cleanArray[0] as? String, "Infinity")
            XCTAssertTrue(cleanArray[1] is String)
            XCTAssertEqual(cleanArray[1] as? String, "NaN")
            XCTAssertTrue(cleanArray[2] is String)
            XCTAssertEqual(cleanArray[2] as? String, "-Infinity")
            XCTAssertTrue(cleanArray[3] is Double)
            XCTAssertEqual(cleanArray[3] as? Double, Double.greatestFiniteMagnitude)
            XCTAssertTrue(cleanArray[4] is Double)
            XCTAssertEqual(cleanArray[4] as? Double, Double.leastNormalMagnitude)
            XCTAssertTrue(cleanArray[5] is Double)
            XCTAssertEqual(cleanArray[5] as? Double, 1.0)
            XCTAssertTrue(cleanArray[6] is Double)
            XCTAssertEqual(cleanArray[6] as? Double, 0.0)
            XCTAssertTrue(cleanArray[7] is Double)
            XCTAssertEqual(cleanArray[7] as? Double, -1.0)
            XCTAssertTrue(cleanArray[8] is Int)
            XCTAssertEqual(cleanArray[8] as? Int, 35)
            XCTAssertTrue(cleanArray[9] is String)
            XCTAssertTrue(cleanArray[10] is String)
            XCTAssertEqual(cleanArray[10] as? String, "https://www.rudderstack.com")
            XCTAssertTrue(cleanArray[11] is [String:Any])
            if let nestedDict = cleanArray[11] as? [String:Any] {
                XCTAssertTrue(nestedDict["date"] is String)
                XCTAssertTrue(nestedDict["url"] is String)
                XCTAssertEqual(nestedDict["url"] as? String, "https://www.rudderstack.com")
                XCTAssertTrue(nestedDict["nestedDict"] is [String:Any])
                if let nestedDict = nestedDict["nestedDict"] as? [String:Any] {
                    XCTAssertTrue(nestedDict["infinity"] is String)
                    XCTAssertEqual(nestedDict["infinity"] as? String, "Infinity")
                    XCTAssertTrue(nestedDict["negativeInfinity"] is String)
                    XCTAssertEqual(nestedDict["negativeInfinity"] as? String, "-Infinity")
                    XCTAssertTrue(nestedDict["NaN"] is String)
                    XCTAssertEqual(nestedDict["NaN"] as? String, "NaN")
                    XCTAssertTrue(nestedDict["max"] is Double)
                    XCTAssertEqual(nestedDict["max"] as? Double, Double.greatestFiniteMagnitude)
                } else {
                    XCTFail("Nested Dict shouldn't be nil")
                }
                XCTAssertTrue(nestedDict["nestedArray"] is [Any])
                if let nestedArray = nestedDict["nestedArray"] as? [Any] {
                    XCTAssertTrue(nestedArray[0] is String)
                    XCTAssertEqual(nestedArray[0] as? String, "Infinity")
                    XCTAssertTrue(nestedArray[1] is String)
                    XCTAssertEqual(nestedArray[1] as? String, "NaN")
                    XCTAssertTrue(nestedArray[2] is Double)
                    XCTAssertEqual(nestedArray[2] as? Double, Double.greatestFiniteMagnitude)
                    XCTAssertTrue(nestedArray[3] is [String:Any])
                    if let nestedDict = nestedArray[3] as? [String:Any] {
                        XCTAssertTrue(nestedDict["date"] is String)
                        XCTAssertTrue(nestedDict["url"] is String)
                        XCTAssertEqual(nestedDict["url"] as? String, "https://www.rudderstack.com")
                    } else {
                        XCTFail("Nested Dict shouldn't be nil")
                    }
                } else {
                    XCTFail("Nested Array shouldn't be nil")
                }
            } else {
                XCTFail("Nested Dict shouldn't be nil")
            }
        }
    }
    
    func testIsInvalidNumber() {
        XCTAssertTrue(RSUtils.isSpecialFloating(Double.infinity as NSNumber))
        XCTAssertTrue(RSUtils.isSpecialFloating(Double.nan as NSNumber))
        XCTAssertTrue(RSUtils.isSpecialFloating(-Double.infinity as NSNumber))
        XCTAssertFalse(RSUtils.isSpecialFloating(Double.greatestFiniteMagnitude as NSNumber))
        XCTAssertFalse(RSUtils.isSpecialFloating(Double.leastNormalMagnitude as NSNumber))
        XCTAssertFalse(RSUtils.isSpecialFloating(1.0))
        XCTAssertFalse(RSUtils.isSpecialFloating(0.0))
        XCTAssertFalse(RSUtils.isSpecialFloating(-1.0))
        XCTAssertFalse(RSUtils.isSpecialFloating(35))
    }

    func testSerialize() {
        let dictObj : [String:Any] = [
            "name" : "Desu Sai Venkat",
            "company" : "RudderStack",
            "date": Date(),
            "infinity": Double.infinity,
            "url": URL(string: "https://www.rudderstack.com")!,
            "NaN": Double.nan,
            "city" : "Hyderabad"]
        let jsonString = RSUtils.serialize(dictObj)
        print(jsonString)
        XCTAssertNotNil(jsonString)
        // ensure that url, nan, date are sanitized in the string
        XCTAssertTrue(jsonString.contains("rudderstack.com"))
        XCTAssertTrue(jsonString.contains("NaN"))
        XCTAssertTrue(jsonString.contains("date"))
        XCTAssertTrue(jsonString.contains("Infinity"))
    }
}
