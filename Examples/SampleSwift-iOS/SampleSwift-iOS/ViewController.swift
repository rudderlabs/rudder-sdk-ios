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
    var client: RSClient!
    
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
        Task(name: "Order completed"),
        Task(name: "Multiple Track"),
        Task(name: "Multiple Flush From Background"),
        Task(name: "Multiple Flush and Multiple Track"),
        Task(name: "Multiple Track, Screen, Alias, Group, Identify"),
        Task(name: "Multiple Track, Screen, Alias, Group, Identify, Device Token, AnonymousId, AdvertisingId, AppTracking Consent")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        client = (UIApplication.shared.delegate as? AppDelegate)!.client
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
            case 0:
                client.identify("test_user_id", traits: [
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
                client.identify("test_user_id")
                
            case 2:
                client.track("single_track_call", properties: [
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
                client.track("single_track_call")
            case 4:
                client.alias("new_user_id")
            case 5:
                client.screen("ViewController", properties: ["key_1": "value_1"])
            case 6:
                client.screen("ViewController")
            case 7:
                client.group("test_group_id", traits: ["key_1": "value_1"])
            case 8:
                client.group("test_group_id")
            case 9:
                client.setAnonymousId("anonymous_id_1")
            case 10:
                client.setDeviceToken("device_token_1")
            case 11:
                client.setAdvertisingId("advertising_id_1")
            case 12:
                client.setOptOutStatus(false)
            case 13:
                client.setOptOutStatus(true)
            case 14:
                client.reset(and: false)
            case 15:
                client.flush()
            case 16:
                client.setAnonymousId("anonymous_id_2")
            case 17:
                client.setDeviceToken("device_token_2")
            case 18:
                client.setAdvertisingId("advertising_id_2")
            case 19:
                let option = Option()
                
                option.putIntegration("key-5", isEnabled: true)
                option.putIntegration("key-6", isEnabled: true)
                option.putIntegration("key-7", isEnabled: true)
                option.putIntegration("key-8", isEnabled: false)
                
                client.setOption(option)
            case 20:
                let option = IdentifyOption()
                option.putExternalId("value-1", to: "key-1")
                option.putExternalId("value-2", to: "key-2")
                
                option.putIntegration("key-5", isEnabled: true)
                option.putIntegration("key-6", isEnabled: true)
                option.putIntegration("key-7", isEnabled: false)
                option.putIntegration("key-8", isEnabled: false)
                
                option.putCustomContext(["Key-01": "value-1"], for: "key-9")
                option.putCustomContext(["Key-02": "value-1"], for: "key-10")
                option.putCustomContext(["Key-03": "value-1"], for: "key-11")
                option.putCustomContext(["Key-04": "value-1"], for: "key-12")
                client.identify("test_user_id", option: option)
            case 21:
                let option = MessageOption()
                
                option.putIntegration("key-5", isEnabled: false)
                option.putIntegration("key-6", isEnabled: true)
                option.putIntegration("key-7", isEnabled: false)
                option.putIntegration("key-8", isEnabled: true)
                
                option.putCustomContext(["Key-01": "value-1"], for: "key-9")
                option.putCustomContext(["Key-02": "value-2"], for: "key-10")
                client.track("single_track_call", option: option)
            case 22:
                client.startSession()
            case 23:
                client.endSession()
            case 24:
                client.startSession(1234567890)
            case 25:
                if let context = client.context, let dictionaryValue = context.dictionaryValue {
                    print(dictionaryValue)
                }
            case 26:
                client.track("allow_list_track", properties: [
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
                client.track("deny_list_track", properties: [
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
                client.track("Order Done", properties: getProperties())
            case 29:
                client.track("Order Completed", properties: getProperties())
            case 30:
                for i in 1...50 {
                    client.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
        /*
        case 4:
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 1, Flush No. \(i)")
                    client.flush()
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 2, Flush No. \(i)")
                    client.flush()
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 3, Flush No. \(i)")
                    client.flush()
                }
            }*/
        /*case 6:
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 1A, Track No. \(i)")
                    client.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 1, Flush No. \(i)")
                    client.flush()
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1001...2000 {
                    print("From Thread 2A, Track No. \(i)")
                    client.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 2, Flush No. \(i)")
                    client.flush()
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 2001...3000 {
                    print("From Thread 3A, Track No. \(i)")
                    client.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 3, Flush No. \(i)")
                    client.flush()
                }
            }
        case 9:
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 1A, Track No. \(i)")
                    client.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            }
                        
            DispatchQueue.global(qos: .background).async {
                for i in 1001...2000 {
                    print("From Thread 2A, Screen No. \(i)")
                    client.screen("Screen \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            }

            DispatchQueue.global(qos: .background).async {
                for i in 2001...3000 {
                    print("From Thread 3A, Group No. \(i)")
                    client.group("Group \(i)", traits: ["time": "\(Date().timeIntervalSince1970)"])
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 3001...4000 {
                    print("From Thread 4A, Alias No. \(i)")
                    client.alias("Alias \(i)")
                }
            }

            DispatchQueue.global(qos: .background).async {
                for i in 4001...5000 {
                    print("From Thread 5A, Identify No. \(i)")
                    client.identify("Identify \(i)", traits: ["time": Date().timeIntervalSince1970])
                }
            }
        case 10:
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("From Thread 1A, Track No. \(i)")
                    if i % 2 == 0 {
                        client.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                    } else {
                        client.setAdvertisingId("Advertising Id \(i)")
                    }
                }
            }
                        
            DispatchQueue.global(qos: .background).async {
                for i in 1001...2000 {
                    print("From Thread 2A, Screen No. \(i)")
                    if i % 2 == 0 {
                        client.screen("Screen \(i)", properties: ["time": Date().timeIntervalSince1970])
                    } else {
                        client.setAnonymousId("Anonymous Id \(i)")
                    }
                }
            }

            DispatchQueue.global(qos: .background).async {
                for i in 2001...3000 {
                    print("From Thread 3A, Group No. \(i)")
                    if i % 2 == 0 {
                        client.group("Group \(i)", traits: ["time": "\(Date().timeIntervalSince1970)"])
                    } else {
                        client.setDeviceToken("Device Token \(i)")
                    }
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                for i in 3001...4000 {
                    print("From Thread 4A, Alias No. \(i)")
                    if i % 2 == 0 {
                        client.alias("Alias \(i)")
                    } else {
                        client.setAppTrackingConsent(.authorize)
                    }
                }
            }

            DispatchQueue.global(qos: .background).async {
                for i in 4001...5000 {
                    print("From Thread 5A, Identify No. \(i)")
                    if i % 2 == 0 {
                    client.identify("Identify \(i)", traits: ["time": Date().timeIntervalSince1970])
                    } else {
                        client.setDeviceToken("Device Token \(i)")
                        client.setAppTrackingConsent(.authorize)
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
