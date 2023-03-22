//
//  ServerConfigManagerTests.swift
//  Tests
//
//  Created by Desu Sai Venkat on 02/06/22.
//

import XCTest
import Rudder

class ServerConfigManagerTests: XCTestCase {
    
    static let writeKey = "1pTxG1Tqxr7FCrqIy7j0p28AENV"
    static let authToken = writeKey.toBase64()
    
    static let anonymousId = "2248a26b-339b-4b62-90e0-5a004649267d"
    static let anonymousIdToken = anonymousId.toBase64()
    
    
    var rsServerConfigManager: RSServerConfigManager!
    var rsPreferenceManager:RSPreferenceManager!
    var configJSON:String!
    override func setUpWithError() throws {
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
        "areTransformationsConnected" : true,
        "id": "23VDGOseYM8ymh2iIjsSErewmMW",
        "name": "Firebase Devv",
        "enabled": true,
        "updatedAt": "2022-05-25T11:31:31.197Z",
        "destinationDefinition": {
          "name": "FIREBASE",
          "displayName": "Firebase",
          "updatedAt": "2022-05-13T09:31:26.459Z"
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
        "areTransformationsConnected" : true,
        "id": "23VDGOseYM8ymh2iIjsSEreapd",
        "name": "AppCenter Dev",
        "enabled": true,
        "updatedAt": "2022-05-25T11:31:31.197Z",
        "destinationDefinition": {
          "name": "APPCENTER",
          "displayName": "App Center",
          "updatedAt": "2022-05-13T09:31:26.459Z"
        }
      }
    ]
  }
}
"""
        rsPreferenceManager = RSPreferenceManager()
        rsPreferenceManager.saveConfigJson(configJSON)
        
        let rsConfig = RSConfigBuilder().withControlPlaneUrl("https://invalid-rudder.com").build()
        let dataResidencyManager = RSDataResidencyManager(rsConfig: rsConfig)
        let rsNetworkManager = RSNetworkManager(config: rsConfig, andAuthToken:ServerConfigManagerTests.authToken, andAnonymousIdToken: ServerConfigManagerTests.anonymousIdToken, andDataResidencyManager: dataResidencyManager)
        
        rsServerConfigManager = RSServerConfigManager(ServerConfigManagerTests.writeKey, rudderConfig: rsConfig, andNetworkManager: rsNetworkManager!)
        sleep(12)
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testDestinationsWithTransformationsEnabled() {
        let destinationsWithTransformationsEnabled:[String:String] = rsServerConfigManager.getDestinationsWithTransformationsEnabled()
        print(destinationsWithTransformationsEnabled)
        XCTAssertEqual(destinationsWithTransformationsEnabled["App Center"], "23VDGOseYM8ymh2iIjsSEreapd")
        XCTAssertEqual(destinationsWithTransformationsEnabled["Firebase"], "23VDGOseYM8ymh2iIjsSErewmMW")
    }
}
