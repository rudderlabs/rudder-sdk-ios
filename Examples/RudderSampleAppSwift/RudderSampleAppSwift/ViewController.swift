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

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let taskList: [Task] = [
        Task(name: "Identify"),
        Task(name: "Single Track"),
        Task(name: "Multiple Track"),
        Task(name: "Single Flush"),
        Task(name: "Multiple Flush From Background"),
        Task(name: "Alias"),
        Task(name: "Multiple Flush and Multiple Track"),
        Task(name: "Screen without properties"),
        Task(name: "Screen with properties"),
        Task(name: "Reset"),
        Task(name: "Group"),
        Task(name: "Opt Out"),
        Task(name: "Opt In"),
        Task(name: "Denylist Track")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.dataSource = self
        tableView.delegate = self
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
                RSClient.sharedInstance()?.identify("test_user_id", traits: [
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
                RSClient.sharedInstance()?.track("single_track_call", properties: [
                    "integerValue": 42,
                    "stringValue": "Hello, World!",
                    "boolValue": true,
                    "doubleValue": 3.14159,
                    "arrayValue": [1, 2, 3, 4, 5],
                    "dictionaryValue": ["key1": "value1", "key2": Date(), "key-3": ["key1": URL(string: "https://www.example.com")!, "key2": Date()] as [String : Any]] as [String : Any],
                    "urlValue": URL(string: "https://www.example.com")!,
                    "dateValue": Date()
                ])
            case 2:
                for i in 1...50 {
                    RSClient.sharedInstance()?.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                }
            case 3:
                RSClient.sharedInstance()?.flush()
            case 4:
                DispatchQueue.global(qos: .background).async {
                    for i in 1...1000 {
                        print("From Thread 1, Flush No. \(i)")
                        RSClient.sharedInstance()?.flush()
                    }
                }
                
                DispatchQueue.global(qos: .background).async {
                    for i in 1...1000 {
                        print("From Thread 2, Flush No. \(i)")
                        RSClient.sharedInstance()?.flush()
                    }
                }
                
                DispatchQueue.global(qos: .background).async {
                    for i in 1...1000 {
                        print("From Thread 3, Flush No. \(i)")
                        RSClient.sharedInstance()?.flush()
                    }
                }
            case 5:
                RSClient.sharedInstance()?.alias("new_user_id")
            case 6:
                DispatchQueue.global(qos: .background).async {
                    for i in 1...1000 {
                        print("From Thread 1A, Track No. \(i)")
                        RSClient.sharedInstance()?.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                    }
                }
                
                DispatchQueue.global(qos: .background).async {
                    for i in 1...1000 {
                        print("From Thread 1, Flush No. \(i)")
                        RSClient.sharedInstance()?.flush()
                    }
                }
                
                DispatchQueue.global(qos: .background).async {
                    for i in 1001...2000 {
                        print("From Thread 2A, Track No. \(i)")
                        RSClient.sharedInstance()?.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                    }
                }
                
                DispatchQueue.global(qos: .background).async {
                    for i in 1...1000 {
                        print("From Thread 2, Flush No. \(i)")
                        RSClient.sharedInstance()?.flush()
                    }
                }
                
                DispatchQueue.global(qos: .background).async {
                    for i in 2001...3000 {
                        print("From Thread 3A, Track No. \(i)")
                        RSClient.sharedInstance()?.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                    }
                }
                
                DispatchQueue.global(qos: .background).async {
                    for i in 1...1000 {
                        print("From Thread 3, Flush No. \(i)")
                        RSClient.sharedInstance()?.flush()
                    }
                }
            case 7:
                RSClient.sharedInstance()?.screen("ViewController")
            case 8:
                RSClient.sharedInstance()?.screen("ViewController", properties: ["key_1": "value_1"])
            case 9:
                RSClient.sharedInstance()?.reset(false)
            case 10:
                RSClient.sharedInstance()?.group("test_group_id")
            case 11:
                RSClient.sharedInstance()?.optOut(true)
            case 12:
                RSClient.sharedInstance()?.optOut(false)
            case 13:
                RSClient.sharedInstance()?.track("denylist_track_call", properties: [
                    "integerValue": 42,
                    "stringValue": "Hello, World!",
                    "boolValue": true,
                    "doubleValue": 3.14159,
                    "arrayValue": [1, 2, 3, 4, 5],
                    "dictionaryValue": ["key1": "value1", "key2": Date(), "key-3": ["key1": URL(string: "https://www.example.com")!, "key2": Date()] as [String : Any]] as [String : Any],
                    "urlValue": URL(string: "https://www.example.com")!,
                    "dateValue": Date()
                ])
            default:
                break
        }
    }
}
