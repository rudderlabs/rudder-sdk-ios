//
//  RudderTests.swift
//  RudderTests
//
//  Created by Desu Sai Venkat on 26/10/22.
//

import XCTest
@testable import Rudder

class RudderTests: XCTestCase {
    
    let writeKey = "123@23456"
    var rsConfig: RSConfig!
    var rsServerConfigManager: RSServerConfigManager!
    var rsServerConfigSource: RSServerConfigSource!
    var configJson: String!
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    
    func testWithBothResidenciesInSourceConfig() {
        
        configJson = """
{
  "isHosted": true,
  "source": {
    "config": {
      "statsCollection": {
        "errorReports": {
          "enabled": false
        },
        "metrics": {
          "enabled": false
        }
      }
    },
    "liveEventsConfig": {

    },
    "dataPlaneUrls": {
      "eu": "https://rudderstacgwyx-eu.dataplane.rudderstack.com",
      "us": "https://rudderstacgwyx-us.dataplane.rudderstack.com"
    },
    "id": "2GcaJMDRDWtZsZdeusASLcpyamz",
    "name": "Android Dev 2",
    "writeKey": "2GcaJLm1a8cSKbfCZdKNGn5XDcO",
    "enabled": true,
    "sourceDefinitionId": "1QGzOQGVLM35GgtteFH1vYCE0WT",
    "createdBy": "2FkbV0e3wAJaiqxfFkWVqDrtT7I",
    "workspaceId": "2FkbaBpkwsVa3A3B4ZMZ365BVC3",
    "deleted": false,
    "transient": false,
    "secretVersion": null,
    "createdAt": "2022-10-25T09:30:52.830Z",
    "updatedAt": "2022-10-25T09:30:52.830Z",
    "connections": [
      {
        "id": "2GcaQeqMFrit8Wju1xDuEA5KgU6",
        "sourceId": "2GcaJMDRDWtZsZdeusASLcpyamz",
        "destinationId": "2GcaQQ7ce7kPlhvnbQiINUXOa0h",
        "enabled": true,
        "deleted": false,
        "createdAt": "2022-10-25T09:31:50.331Z",
        "updatedAt": "2022-10-25T09:31:50.331Z"
      }
    ],
    "destinations": [

    ],
    "sourceDefinition": {
      "options": null,
      "config": null,
      "configSchema": null,
      "uiConfig": null,
      "id": "1QGzOQGVLM35GgtteFH1vYCE0WT",
      "name": "Android",
      "displayName": "Android",
      "category": null,
      "createdAt": "2019-09-02T08:08:08.373Z",
      "updatedAt": "2020-06-18T11:54:00.449Z"
    }
  }
}
"""
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig);
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-eu.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
    }
    
    func testWithOnlyUSInSourceConfig() {
        
        configJson = """
{
  "isHosted": true,
  "source": {
    "config": {
      "statsCollection": {
        "errorReports": {
          "enabled": false
        },
        "metrics": {
          "enabled": false
        }
      }
    },
    "liveEventsConfig": {

    },
    "dataPlaneUrls": {
      "us": "https://rudderstacgwyx-us.dataplane.rudderstack.com"
    },
    "id": "2GcaJMDRDWtZsZdeusASLcpyamz",
    "name": "Android Dev 2",
    "writeKey": "2GcaJLm1a8cSKbfCZdKNGn5XDcO",
    "enabled": true,
    "sourceDefinitionId": "1QGzOQGVLM35GgtteFH1vYCE0WT",
    "createdBy": "2FkbV0e3wAJaiqxfFkWVqDrtT7I",
    "workspaceId": "2FkbaBpkwsVa3A3B4ZMZ365BVC3",
    "deleted": false,
    "transient": false,
    "secretVersion": null,
    "createdAt": "2022-10-25T09:30:52.830Z",
    "updatedAt": "2022-10-25T09:30:52.830Z",
    "connections": [
      {
        "id": "2GcaQeqMFrit8Wju1xDuEA5KgU6",
        "sourceId": "2GcaJMDRDWtZsZdeusASLcpyamz",
        "destinationId": "2GcaQQ7ce7kPlhvnbQiINUXOa0h",
        "enabled": true,
        "deleted": false,
        "createdAt": "2022-10-25T09:31:50.331Z",
        "updatedAt": "2022-10-25T09:31:50.331Z"
      }
    ],
    "destinations": [

    ],
    "sourceDefinition": {
      "options": null,
      "config": null,
      "configSchema": null,
      "uiConfig": null,
      "id": "1QGzOQGVLM35GgtteFH1vYCE0WT",
      "name": "Android",
      "displayName": "Android",
      "category": null,
      "createdAt": "2019-09-02T08:08:08.373Z",
      "updatedAt": "2020-06-18T11:54:00.449Z"
    }
  }
}
"""
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig);
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-us.dataplane.rudderstack.com/")
    }
    
    func testWithOnlyEUInSourceConfig() {
        
        configJson = """
{
  "isHosted": true,
  "source": {
    "config": {
      "statsCollection": {
        "errorReports": {
          "enabled": false
        },
        "metrics": {
          "enabled": false
        }
      }
    },
    "liveEventsConfig": {

    },
    "dataPlaneUrls": {
      "eu": "https://rudderstacgwyx-eu.dataplane.rudderstack.com"
    },
    "id": "2GcaJMDRDWtZsZdeusASLcpyamz",
    "name": "Android Dev 2",
    "writeKey": "2GcaJLm1a8cSKbfCZdKNGn5XDcO",
    "enabled": true,
    "sourceDefinitionId": "1QGzOQGVLM35GgtteFH1vYCE0WT",
    "createdBy": "2FkbV0e3wAJaiqxfFkWVqDrtT7I",
    "workspaceId": "2FkbaBpkwsVa3A3B4ZMZ365BVC3",
    "deleted": false,
    "transient": false,
    "secretVersion": null,
    "createdAt": "2022-10-25T09:30:52.830Z",
    "updatedAt": "2022-10-25T09:30:52.830Z",
    "connections": [
      {
        "id": "2GcaQeqMFrit8Wju1xDuEA5KgU6",
        "sourceId": "2GcaJMDRDWtZsZdeusASLcpyamz",
        "destinationId": "2GcaQQ7ce7kPlhvnbQiINUXOa0h",
        "enabled": true,
        "deleted": false,
        "createdAt": "2022-10-25T09:31:50.331Z",
        "updatedAt": "2022-10-25T09:31:50.331Z"
      }
    ],
    "destinations": [

    ],
    "sourceDefinition": {
      "options": null,
      "config": null,
      "configSchema": null,
      "uiConfig": null,
      "id": "1QGzOQGVLM35GgtteFH1vYCE0WT",
      "name": "Android",
      "displayName": "Android",
      "category": null,
      "createdAt": "2019-09-02T08:08:08.373Z",
      "updatedAt": "2020-06-18T11:54:00.449Z"
    }
  }
}
"""
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig);
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://rudderstacgwyx-eu.dataplane.rudderstack.com/")
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
    }
    
    func testWhenNoUrlInSourceConfig() {
        configJson = """
{
  "isHosted": true,
  "source": {
    "config": {
      "statsCollection": {
        "errorReports": {
          "enabled": false
        },
        "metrics": {
          "enabled": false
        }
      }
    },
    "liveEventsConfig": {

    },
    "id": "2GcaJMDRDWtZsZdeusASLcpyamz",
    "name": "Android Dev 2",
    "writeKey": "2GcaJLm1a8cSKbfCZdKNGn5XDcO",
    "enabled": true,
    "sourceDefinitionId": "1QGzOQGVLM35GgtteFH1vYCE0WT",
    "createdBy": "2FkbV0e3wAJaiqxfFkWVqDrtT7I",
    "workspaceId": "2FkbaBpkwsVa3A3B4ZMZ365BVC3",
    "deleted": false,
    "transient": false,
    "secretVersion": null,
    "createdAt": "2022-10-25T09:30:52.830Z",
    "updatedAt": "2022-10-25T09:30:52.830Z",
    "connections": [
      {
        "id": "2GcaQeqMFrit8Wju1xDuEA5KgU6",
        "sourceId": "2GcaJMDRDWtZsZdeusASLcpyamz",
        "destinationId": "2GcaQQ7ce7kPlhvnbQiINUXOa0h",
        "enabled": true,
        "deleted": false,
        "createdAt": "2022-10-25T09:31:50.331Z",
        "updatedAt": "2022-10-25T09:31:50.331Z"
      }
    ],
    "destinations": [

    ],
    "sourceDefinition": {
      "options": null,
      "config": null,
      "configSchema": null,
      "uiConfig": null,
      "id": "1QGzOQGVLM35GgtteFH1vYCE0WT",
      "name": "Android",
      "displayName": "Android",
      "category": null,
      "createdAt": "2019-09-02T08:08:08.373Z",
      "updatedAt": "2020-06-18T11:54:00.449Z"
    }
  }
}
"""
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https://some.random.dataplane.com").build()
        rsServerConfigManager = RSServerConfigManager(writeKey, rudderConfig: rsConfig);
        rsServerConfigSource = rsServerConfigManager._parseConfig(configJson)
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(EU).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataResidencyServer(US).withDataPlaneUrl("https://some.random.dataplane.com").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://some.random.dataplane.com/")
        
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).withDataPlaneUrl("https::/somerandomdataplanecom").build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://hosted.rudderlabs.com/")
        
        rsConfig = RSConfigBuilder().withLoglevel(RSLogLevelVerbose).build()
        XCTAssertEqual(RSUtils.getDataPlaneUrl(from: rsServerConfigSource, andRSConfig: rsConfig), "https://hosted.rudderlabs.com/")
        
    }
}
