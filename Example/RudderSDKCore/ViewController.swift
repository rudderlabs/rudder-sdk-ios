//
//  ViewController.swift
//  RudderSDKCore
//
//  Created by arnab on 10/16/2019.
//  Copyright (c) 2019 arnab. All rights reserved.
//

import UIKit
import RudderSDKCore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        AppDelegate.rudderClient?.track(message: RudderMessageBuilder()
            .withEventName(eventName: "level_up")
            .withEventProperties(properties: TrackPropertyBuilder()
                .setCategory(category: "test_category")
                .build())
            .withUserId(userId: "test_user_id")
            .build()
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

