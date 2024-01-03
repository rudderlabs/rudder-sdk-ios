//
//  ViewController.swift
//  ExampleSwift
//
//  Created by Arnab Pal on 09/05/20.
//  Copyright © 2020 RudderStack. All rights reserved.
//

import UIKit
import Rudder

struct Events {
    let name: String
    let properties: [String: Any]?
}

struct Task {
    let name: String
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var instance1: RSClient!
    var instance2: RSClient!
    
    let taskList: [Task] = [
        Task(name: "Identify with traits"),
        Task(name: "Identify without traits"),
        Task(name: "Single Track with properties"),
        Task(name: "Single Track without properties"),
        Task(name: "Alias"),
        Task(name: "Screen with properties"),
        Task(name: "Screen without properties"),
        Task(name: "Group with traits"),
        Task(name: "Group without traits"),
        Task(name: "Set AnonymousId"),
        Task(name: "Set Device Token"),
        Task(name: "Set AdvertisingId"),
        Task(name: "Opt In"),
        Task(name: "Opt Out"),
        Task(name: "Reset"),
        Task(name: "Single Flush"),
        Task(name: "Update AnonymousId"),
        Task(name: "Update Device Token"),
        Task(name: "Update AdvertisingId"),
        Task(name: "Set Option at root level"),
        Task(name: "Set Option at identify"),
        Task(name: "Set Option at track"),
        Task(name: "Start session"),
        Task(name: "End session"),
        Task(name: "Start session with id"),
        Task(name: "Get Context"),
        Task(name: "Allowlist track"),
        Task(name: "Denylist track"),
        Task(name: "Order done"),
        Task(name: "Multiple Track for Instance 1"),
        Task(name: "Multiple Track for Instance 2"),
        Task(name: "Multiple Track for Instance 1 & 2"),
        Task(name: "Multiple Flush From Background"),
        Task(name: "Multiple Flush and Multiple Track"),
        Task(name: "Multiple Track, Screen, Alias, Group, Identify"),
        Task(name: "Multiple Track, Screen, Alias, Group, Identify, Device Token, AnonymousId, AdvertisingId, AppTracking Consent")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        guard let path = Bundle.main.path(forResource: "RudderConfig", ofType: "plist"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let rudderConfig = try? PropertyListDecoder().decode(RudderConfig.self, from: data) else {
            return
        }
        
        let config: RSConfig = RSConfig(writeKey: rudderConfig.WRITE_KEY)
            .dataPlaneURL(rudderConfig.DEV_DATA_PLANE_URL)
            .controlPlaneURL(rudderConfig.DEV_CONTROL_PLANE_URL)
            .loglevel(.verbose)
            .trackLifecycleEvents(false)
            .flushQueueSize(100)
            .sleepTimeOut(100)
            .dbCountThreshold(100000)
        
        instance1 = RudderClient.initialize(config: config)
        
        let config2 = RSConfig(writeKey: "2CYw61Oy8Wsrkh0ZHf65QDLYpDJ")
            .dataPlaneURL(rudderConfig.DEV_DATA_PLANE_URL)
            .controlPlaneURL(rudderConfig.DEV_CONTROL_PLANE_URL)
            .loglevel(.verbose)
            .trackLifecycleEvents(false)
            .flushQueueSize(100)
            .sleepTimeOut(100)
            .dbCountThreshold(100000)
        
        instance2 = RudderClient.initialize(config: config2, instanceName: "instance_2")
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = taskList[indexPath.row]
        cell.textLabel?.text = item.name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            /*case 0:
                RSClient.sharedInstance().identify("test_user_id", traits: [
                    "integerValue": 42,
                    "stringValue": "Hello, World!",
                    "boolValue": true,
                    "doubleValue": 3.14159,
                    "arrayValue": [1, 2, 3, 4, 5],
                    "dictionaryValue": ["key1": "value1", "key2": "value2"],
                    "urlValue": URL(string: "https://www.example.com")!,
                    "dateValue": Date()
                ])
            case 1:
                RSClient.sharedInstance().identify("test_user_id")
                
            case 2:
                RSClient.sharedInstance().track("single_track_call", properties: [
                    "integerValue": 42,
                    "stringValue": "Hello, World!",
                    "boolValue": true,
                    "doubleValue": 3.14159,
                    "arrayValue": [1, 2, 3, 4, 5],
                    "dictionaryValue": ["key1": "value1", "key2": Date(), "key-3": ["key1": URL(string: "https://www.example.com")!, "key2": Date()] as [String : Any]] as [String : Any],
                    "urlValue": URL(string: "https://www.example.com")!,
                    "dateValue": Date()
                ])
            case 3:
                RSClient.sharedInstance().track("single_track_call")
            case 4:
                RSClient.sharedInstance().alias("new_user_id")
            case 5:
                RSClient.sharedInstance().screen("ViewController", properties: ["key_1": "value_1"])
            case 6:
                RSClient.sharedInstance().screen("ViewController")
            case 7:
                RSClient.sharedInstance().group("test_group_id", traits: ["key_1": "value_1"])
            case 8:
                RSClient.sharedInstance().group("test_group_id")
            case 9:
                RSClient.sharedInstance().setAnonymousId("anonymous_id_1")
            case 10:
                RSClient.sharedInstance().setDeviceToken("device_token_1")
            case 11:
                RSClient.sharedInstance().setAdvertisingId("advertising_id_1")
            case 12:
                RSClient.sharedInstance().setOptOutStatus(false)
            case 13:
                RSClient.sharedInstance().setOptOutStatus(true)
            case 14:
                RSClient.sharedInstance().reset()
            case 15:
                RSClient.sharedInstance().flush()
            case 16:
                RSClient.sharedInstance().setAnonymousId("anonymous_id_2")
            case 17:
                RSClient.sharedInstance().setDeviceToken("device_token_2")
            case 18:
                RSClient.sharedInstance().setAdvertisingId("advertising_id_2")
            case 19:
                let option = RSOption()
                
                option.putIntegration("key-5", isEnabled: true)
                option.putIntegration("key-6", isEnabled: true)
                option.putIntegration("key-7", isEnabled: true)
                option.putIntegration("key-8", isEnabled: false)
                
                RSClient.sharedInstance().setOption(option)
            case 20:
                let option = RSOption()
                option.putExternalId("key-1", withId: "value-1")
                option.putExternalId("key-2", withId: "value-2")
                
                option.putIntegration("key-5", isEnabled: true)
                option.putIntegration("key-6", isEnabled: true)
                option.putIntegration("key-7", isEnabled: false)
                option.putIntegration("key-8", isEnabled: false)
                
                option.putCustomContext(["Key-01": "value-1"], withKey: "key-9")
                option.putCustomContext(["Key-02": "value-1"], withKey: "key-10")
                option.putCustomContext(["Key-03": "value-1"], withKey: "key-11")
                option.putCustomContext(["Key-04": "value-1"], withKey: "key-12")
                RSClient.sharedInstance().identify("test_user_id", option: option)
            case 21:
                let option = RSOption()
                option.putExternalId("key-3", withId: "value-3")
                option.putExternalId("key-4", withId: "value-4")
                
                option.putIntegration("key-5", isEnabled: false)
                option.putIntegration("key-6", isEnabled: true)
                option.putIntegration("key-7", isEnabled: false)
                option.putIntegration("key-8", isEnabled: true)
                
                option.putCustomContext(["Key-01": "value-1"], withKey: "key-9")
                option.putCustomContext(["Key-02": "value-2"], withKey: "key-10")
                RSClient.sharedInstance().track("single_track_call", option: option)
            case 22:
                RSClient.sharedInstance().startSession()
            case 23:
                RSClient.sharedInstance().endSession()
            case 24:
                RSClient.sharedInstance().startSession(1234567890)
            case 25:
                if let context = RSClient.sharedInstance().context {
                    print(context.dictionaryValue)
                }
            case 26:
                RSClient.sharedInstance().track("allow_list_track", properties: [
                    "integerValue": 42,
                    "stringValue": "Hello, World!",
                    "boolValue": true,
                    "doubleValue": 3.14159,
                    "arrayValue": [1, 2, 3, 4, 5],
                    "dictionaryValue": ["key1": "value1", "key2": Date(), "key-3": ["key1": URL(string: "https://www.example.com")!, "key2": Date()] as [String : Any]] as [String : Any],
                    "urlValue": URL(string: "https://www.example.com")!,
                    "dateValue": Date()
                ])
            case 27:
                RSClient.sharedInstance().track("deny_list_track", properties: [
                    "integerValue": 42,
                    "stringValue": "Hello, World!",
                    "boolValue": true,
                    "doubleValue": 3.14159,
                    "arrayValue": [1, 2, 3, 4, 5],
                    "dictionaryValue": ["key1": "value1", "key2": Date(), "key-3": ["key1": URL(string: "https://www.example.com")!, "key2": Date()] as [String : Any]] as [String : Any],
                    "urlValue": URL(string: "https://www.example.com")!,
                    "dateValue": Date()
                ])
            case 28:
                RSClient.sharedInstance().track("Order Done", properties: getProperties())*/
            case 29:
                for i in 1...5000 {
                    instance1.track("track_\(i)")
                }
            case 30:
                for i in 5000...10000 {
                    instance2.track("track_\(i)")
                }
            case 31:
                for i in 1...5000 {
                    instance1.track("track_\(i)")
                    instance2.track("track_\(i)")
                }
        /*case 2:
            for i in 1...50 {
                RSClient.sharedInstance().track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
            }
        case 4:
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 1, Flush No. \(i)")
                    RSClient.sharedInstance().flush()
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 2, Flush No. \(i)")
                    RSClient.sharedInstance().flush()
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 3, Flush No. \(i)")
                    RSClient.sharedInstance().flush()
                }
            }*/
        /*case 6:
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 1A, Track No. \(i)")
                    RSClient.sharedInstance().track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 1, Flush No. \(i)")
                    RSClient.sharedInstance().flush()
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1001...2000 {
                    print("From Thread 2A, Track No. \(i)")
                    RSClient.sharedInstance().track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 2, Flush No. \(i)")
                    RSClient.sharedInstance().flush()
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 2001...3000 {
                    print("From Thread 3A, Track No. \(i)")
                    RSClient.sharedInstance().track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 3, Flush No. \(i)")
                    RSClient.sharedInstance().flush()
                }
            }
        case 9:
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 1A, Track No. \(i)")
                    RSClient.sharedInstance().track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            }
                        
            DispatchQueue.global(qos: .background).async {
                for i in 1001...2000 {
                    print("From Thread 2A, Screen No. \(i)")
                    RSClient.sharedInstance().screen("Screen \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            }

            DispatchQueue.global(qos: .background).async {
                for i in 2001...3000 {
                    print("From Thread 3A, Group No. \(i)")
                    RSClient.sharedInstance().group("Group \(i)", traits: ["time": "\(Date().timeIntervalSince1970)"])
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 3001...4000 {
                    print("From Thread 4A, Alias No. \(i)")
                    RSClient.sharedInstance().alias("Alias \(i)")
                }
            }

            DispatchQueue.global(qos: .background).async {
                for i in 4001...5000 {
                    print("From Thread 5A, Identify No. \(i)")
                    RSClient.sharedInstance().identify("Identify \(i)", traits: ["time": Date().timeIntervalSince1970])
                }
            }
        case 10:
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 1A, Track No. \(i)")
                    if i % 2 == 0 {
                        RSClient.sharedInstance().track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                    } else {
                        RSClient.sharedInstance().setAdvertisingId("Advertising Id \(i)")
                    }
                }
            }
                        
            DispatchQueue.global(qos: .background).async {
                for i in 1001...2000 {
                    print("From Thread 2A, Screen No. \(i)")
                    if i % 2 == 0 {
                        RSClient.sharedInstance().screen("Screen \(i)", properties: ["time": Date().timeIntervalSince1970])
                    } else {
                        RSClient.sharedInstance().setAnonymousId("Anonymous Id \(i)")
                    }
                }
            }

            DispatchQueue.global(qos: .background).async {
                for i in 2001...3000 {
                    print("From Thread 3A, Group No. \(i)")
                    if i % 2 == 0 {
                        RSClient.sharedInstance().group("Group \(i)", traits: ["time": "\(Date().timeIntervalSince1970)"])
                    } else {
                        RSClient.sharedInstance().setDeviceToken("Device Token \(i)")
                    }
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 3001...4000 {
                    print("From Thread 4A, Alias No. \(i)")
                    if i % 2 == 0 {
                        RSClient.sharedInstance().alias("Alias \(i)")
                    } else {
                        RSClient.sharedInstance().setAppTrackingConsent(.authorize)
                    }
                }
            }

            DispatchQueue.global(qos: .background).async {
                for i in 4001...5000 {
                    print("From Thread 5A, Identify No. \(i)")
                    if i % 2 == 0 {
                    RSClient.sharedInstance().identify("Identify \(i)", traits: ["time": Date().timeIntervalSince1970])
                    } else {
                        RSClient.sharedInstance().setDeviceToken("Device Token \(i)")
                        RSClient.sharedInstance().setAppTrackingConsent(.authorize)
                    }
                }
            }
        */
        default:
            break
        }
    }
    
    func getProperties() -> [String: Any] {
        let products: [String: Any] = [
            RSKeys.Ecommerce.productId: "1001",
            RSKeys.Ecommerce.productName: "Books-1",
            RSKeys.Ecommerce.category: "Books",
            RSKeys.Ecommerce.sku: "Books-sku",
            RSKeys.Ecommerce.quantity: 2,
            RSKeys.Ecommerce.price: 1203.2
        ]
        let fullPath = getDocumentsDirectory().appendingPathComponent("randomFilename")
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
        let properties: [String: Any] = [
            RSKeys.Ecommerce.products: [products],
            "optOutOfSession": true,
            RSKeys.Ecommerce.revenue: 1203,
            RSKeys.Ecommerce.quantity: 10,
            RSKeys.Ecommerce.price: 101.34,
            RSKeys.Ecommerce.productId: "123",
            "revenue_type": "revenue_type_value",
            "receipt": fullPath
        ]
        return properties
    }
}
