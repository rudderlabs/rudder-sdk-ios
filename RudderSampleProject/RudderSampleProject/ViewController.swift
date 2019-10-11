//
//  ViewController.swift
//  RudderSampleProject
//
//  Created by Arnab Pal on 09/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import UIKit
import RudderSdkCore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        AppDelegate.rudderClient?.track(message: RudderMessageBuilder()
            .withEventName(eventName: "level_up")
            .withEventProperties(properties: TrackPropertyBuilder()
                .setCategory(category: "test_category")
                .build())
            .withUserId(userId: "test_user_id")
            .build()
        )
    }


}

