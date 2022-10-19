//
//  SessionViewController.swift
//  RudderSampleAppSwift
//
//  Created by Pallab Maiti on 12/08/22.
//  Copyright © 2022 RudderStack. All rights reserved.
//

import UIKit
import Rudder

struct Task {
    let name: String
}

class SessionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var count = 0
    let queue0 = DispatchQueue(label: "com.knowstack.queue0")
    
    let taskList: [Task] = [Task(name: "Start session"),
                            Task(name: "End session"),
                            Task(name: "Start session with id"),
                            Task(name: "Reset"),
                            Task(name: "Incremental Track"),
                            Task(name: "Incremental Screen"),
                            Task(name: "Incremental Identify"),
                            Task(name: "Incremental Group"),
                            Task(name: "Incremental Alias"),
                            Task(name: "Multiple track & session from multiple thread")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

}

extension SessionViewController: UITableViewDataSource, UITableViewDelegate {
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
            RSClient.sharedInstance()?.startSession()
        case 1:
            RSClient.sharedInstance()?.endSession()
        case 2:
            RSClient.sharedInstance()?.startSession(1234567890)
        case 3:
            RSClient.sharedInstance()?.reset()
        case 4:
            count += 1
            RSClient.sharedInstance()?.track("track_\(count)")
        case 5:
            count += 1
            RSClient.sharedInstance()?.screen("screen_\(count)")
        case 6:
            count += 1
            RSClient.sharedInstance()?.identify("user_\(count)")
        case 7:
            count += 1
            RSClient.sharedInstance()?.group("group_\(count)")
        case 8:
            count += 1
            RSClient.sharedInstance()?.alias("new_user_\(count)")
        case 9:
            DispatchQueue.global(qos: .background).async {
                for i in 1...1000 {
                    print("Background Thread-1 - \(i)")
                    self.call(index: i)
                }
            }
            
            queue0.async {
                let queue = DispatchQueue(label: "com.knowstack.queue1")
                let queue2 = DispatchQueue(label: "com.knowstack.queue2")
                let queue3 = DispatchQueue(label: "com.knowstack.queue3")
                
                queue.async {
                    for i in 1...10000 {
                        print("Thread-2: \(i)")
                        self.call(index: i)
                    }
                }
                queue2.async {
                    for i in 1...10000 {
                        print("Thread-3: \(i)")
                        self.call(index: i)
                    }
                }
                queue3.async {
                    for i in 1...10000 {
                        print("Thread-4: \(i)")
                        self.call(index: i)
                    }
                }
            }
        default: break
        }
    }
    
    func call(index: Int) {
        emptyEvents(index: index)
        func emptyEvents(index: Int) {
            if index % 9 == 0 {
                RSClient.sharedInstance()?.track("Track \(index)", properties: ["time": Date().timeIntervalSince1970])
            } else if index % 9 == 1 {
                RSClient.sharedInstance()?.screen("Screen \(index)", properties: ["time": Date().timeIntervalSince1970])
            } else if index % 9 == 2 {
                RSClient.sharedInstance()?.identify("Identify \(index)", traits: ["time": Date().timeIntervalSince1970])
            } else if index % 9 == 3 {
                RSClient.sharedInstance()?.group("Group \(index)", traits: ["time": Date().timeIntervalSince1970])
            } else if index % 9 == 4 {
                RSClient.sharedInstance()?.alias("Alias \(index)")
            } else if index % 9 == 5 {
                RSClient.sharedInstance()?.startSession()
            } else if index % 9 == 6 {
                RSClient.sharedInstance()?.startSession(Int(Date().timeIntervalSince1970))
            } else if index % 9 == 7 {
                RSClient.sharedInstance()?.endSession()
            } else if index % 9 == 8 {
                RSClient.sharedInstance()?.reset()
            }
        }
    }
}
