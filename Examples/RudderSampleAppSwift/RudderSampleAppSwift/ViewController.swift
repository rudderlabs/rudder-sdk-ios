//
//  ViewController.swift
//  ExampleSwift
//
//  Created by Arnab Pal on 09/05/20.
//  Copyright © 2020 RudderStack. All rights reserved.
//

import UIKit
import Rudder

class ViewController: UIViewController {

    let queue0 = DispatchQueue(label: "com.knowstack.queue0")
    var count = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /*let rudder = RSClient.sharedInstance()
        
        rudder?.screen("Story", properties: [
            "name": "nil"
        ])
        
        rudder?.identify("test_user_id")
        
        rudder?.identify("test_user_id", traits: [
            "key_1": "value_1",
            "key_2": "value_2",
            "int_key": 3,
            "float_key": 4.56,
            "bool_key": true,
            "null_key": NSNull(),
            "date_key": Date(),
            "url_key": URL(fileURLWithPath: "https://rudderstack.com")
        ])
        
        rudder?.identify("test_user_id", traits: [
            "email": "test@gmail.com"
        ])
        
        rudder?.track("track_with_props", properties: [
            "key_1": "value_1",
            "key_2": "value_2",
            "int_key": 3,
            "float_key": 4.56,
            "bool_key": true,
            "null_key": NSNull(),
            "date_key": Date(),
            "url_key": URL(fileURLWithPath: "https://rudderstack.com")
        ])
        
        myclosure { userId in
            rudder?.identify(userId, traits: [
                "key_1": "value_1",
                "key_2": "value_2",
                "int_key": 3,
                "float_key": 4.56,
                "bool_key": true,
                "null_key": NSNull(),
                "date_key": Date(),
                "url_key": URL(fileURLWithPath: "https://rudderstack.com")
            ])
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            rudder?.identify("test_user_id", traits: [
                "key_1": "value_1",
                "key_2": "value_2",
                "int_key": 3,
                "float_key": 4.56,
                "bool_key": true,
                "null_key": NSNull(),
                "date_key": Date(),
                "url_key": URL(fileURLWithPath: "https://rudderstack.com")
            ])
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            rudder?.identify("test_user_id", traits: [
                "key_1": "value_1",
                "key_2": "value_2",
                "int_key": 3,
                "float_key": 4.56,
                "bool_key": true,
                "null_key": NSNull(),
                "date_key": Date(),
                "url_key": URL(fileURLWithPath: "https://rudderstack.com")
            ])
        }
        DispatchQueue.global(qos: .background).async {
            rudder?.track("track_with_props", properties: [:])
        }
        
        DispatchQueue.global(qos: .background).async {            
            rudder?.identify("test_user_id", traits: [
                "key_1": "value_1",
                "key_2": "value_2",
                "int_key": 3,
                "float_key": 4.56,
                "bool_key": true,
                "null_key": NSNull(),
                "date_key": Date(),
                "url_key": URL(fileURLWithPath: "https://rudderstack.com")
            ])
        }*/
    }

    func myclosure(_ completion: @escaping ((String) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion("test_user_id")
        }
    }

    @IBAction func onStartSession(_ sender: UIButton) {
        RSClient.sharedInstance()?.startSession()
    }
    
    @IBAction func onStartSessionWithId(_ sender: UIButton) {
        RSClient.sharedInstance()?.startSession(UUID().uuidString.lowercased())
    }
    
    @IBAction func onTrackAfterNewSession(_ sender: UIButton) {
        RSClient.sharedInstance()?.track("track_after_new_session")
    }
    
    @IBAction func onTrackAfterNewSessionWithId(_ sender: UIButton) {
        RSClient.sharedInstance()?.track("track_after_new_session_with_id")
    }
    
    @IBAction func reset(_ sender: UIButton) {
        RSClient.sharedInstance()?.reset()
    }
    
    @IBAction func onTrackAfterReset(_ sender: UIButton) {
        RSClient.sharedInstance()?.track("track_after_reset")
    }
    
    @IBAction func onTrackAfterBackground(_ sender: UIButton) {
        RSClient.sharedInstance()?.track("track_after_background")
    }
    
    @IBAction func onSimpleTrack(_ sender: UIButton) {
        RSClient.sharedInstance()?.track("simple_track_\(count)")
        count += 1
    }
    
    @IBAction func onMultipleThread(_ sender: UIButton) {
        DispatchQueue.global(qos: .background).async {
            for i in 1...1000 {
                print("From Thread 1A, Track No. \(i)")
                if i % 2 == 0 {
                    RSClient.sharedInstance()?.track("Track \(i)", properties: ["time": Date().timeIntervalSince1970])
                } else {
                    RSClient.sharedInstance()?.startSession("\(Date().timeIntervalSince1970)")
                }
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
    }
    
    func call(index: Int) {
        emptyEvents(index: index)
        func emptyEvents(index: Int) {
            if index % 2 == 0 {
                RSClient.sharedInstance()?.track("Track \(index)", properties: ["time": Date().timeIntervalSince1970])
            } else {
                RSClient.sharedInstance()?.startSession("session_id_\(index)")
            }
        }
    }
}

