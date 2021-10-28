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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let rudder: RSClient? = RSClient.sharedInstance()
        
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
    }


}

