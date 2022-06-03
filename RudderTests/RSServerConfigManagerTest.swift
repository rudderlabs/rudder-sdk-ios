//
//  RSServerConfigManagerTest.swift
//  RudderTests
//
//  Created by Desu Sai Venkat on 02/06/22.
//

import XCTest
import Rudder
import Rudder_Adjust
import Rudder_Firebase

class RSServerConfigManagerTest: XCTestCase {
    
    var rsServerConfigManager: RSServerConfigManager!
    var rsPreferenceManager:RSPreferenceManager!
    var configJSON:String!
    override func setUpWithError() throws {
        
        rsPreferenceManager = RSPreferenceManager()
        configJSON = """
{
  "source": {
    "id": "1pTxG463c2lQ1B0T9uS1NfZIJwS",
    "name": "Android Dev",
    "enabled": true,
    "updatedAt": "2022-02-10T03:59:51.392Z",
    "destinations": [
      {
        "config": {
          "appToken": "adjusttoken",
          "customMappings": [
            {
              "from": "simple_track_with_props",
              "to": "34567"
            }
          ],
          "delay": "",
          "blacklistedEvents": [
            {
              "eventName": ""
            }
          ],
          "whitelistedEvents": [
            {
              "eventName": ""
            }
          ],
          "eventFilteringOption": "disable"
        },
        "transformationId": "1wZzqrP8pG55s2GSN0pAzEiatBL",
        "id": "230BDAJ9l9z4N6FE7YsxA3ZPxHm",
        "name": "Adjust Dev",
        "enabled": true,
        "updatedAt": "2022-05-25T11:56:41.563Z",
        "destinationDefinition": {
          "name": "ADJ",
          "displayName": "Adjust",
          "updatedAt": "2022-01-20T11:42:02.520Z"
        }
      },
      {
        "config": {
          "blacklistedEvents": [
            {
              "eventName": ""
            }
          ],
          "whitelistedEvents": [
            {
              "eventName": ""
            }
          ],
          "eventFilteringOption": "disable"
        },
        "transformationId": "1wZzqrP8pG55s2GSN0pAzEiatBLUS",
        "id": "23VDGOseYM8ymh2iIjsSErewmMW",
        "name": "Firebase Devv",
        "enabled": true,
        "updatedAt": "2022-05-25T11:31:31.197Z",
        "destinationDefinition": {
          "name": "FIREBASE",
          "displayName": "Firebase",
          "updatedAt": "2022-05-13T09:31:26.459Z"
        }
      }
    ]
  }
}
"""
        rsPreferenceManager.saveConfigJson(configJSON)
        
        let rsConfigBuilder = RSConfigBuilder();
        rsConfigBuilder.withFactory(RudderAdjustFactory())
        rsConfigBuilder.withFactory(RudderFirebaseFactory())
        rsConfigBuilder.withControlPlaneUrl("https://invalidurl")
        rsServerConfigManager = RSServerConfigManager.init("1pTxG1Tqxr7FCrqIy7j0p28AENV", rudderConfig: rsConfigBuilder.build())
        sleep(20)
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testGetDestinationToTransformationMapping() {
        let destinationToTransformationMapping:[String:String] = rsServerConfigManager.getDestinationToTransformationMapping()
        XCTAssert(destinationToTransformationMapping["Adjust"] == "1wZzqrP8pG55s2GSN0pAzEiatBL")
        XCTAssert(destinationToTransformationMapping["Firebase"] == "1wZzqrP8pG55s2GSN0pAzEiatBLUS")
        
    }
    
}
