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
    
    let taskList: [Task] = [Task(name: "Identify"),
                            Task(name: "Single Track"),
                            Task(name: "Multiple Track"),
                            Task(name: "Single Flush"),
                            Task(name: "Multiple Flush From Background"),
                            Task(name: "Alias"),
                            Task(name: "Multiple Flush and Multiple Track"),
                            Task(name: "Screen without properties"),
                            Task(name: "Screen with properties"),
                            Task(name: "Multiple Track, Screen, Alias, Group, Identify"),
                            Task(name: "Multiple Track, Screen, Alias, Group, Identify, Device Token, AnonymousId, AdvertisingId, AppTracking Consent")]
    
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
            RSClient.sharedInstance().identify("test_user_id", traits: [
                "key_1": "value_1",
                "key_2": "value_2",
                "int_key": 3,
                "float_key": 4.56,
                "bool_key": true
            ])
        case 1:
            RSClient.sharedInstance().track("single_track_call")
        case 2:
            for i in 1...50 {
                RSClient.sharedInstance().track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
            }
        case 3:
            RSClient.sharedInstance().flush()
        /*case 4:
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
        case 5:
            RSClient.sharedInstance().alias("new_user_id")
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
            }*/
        case 7:
            RSClient.sharedInstance().screen("ViewController")
        case 8:
            RSClient.sharedInstance().screen("ViewController", properties: ["key_1": "value_1"])
        /*case 9:
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
            }*/
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
            
        default:
            break
        }
    }
}
