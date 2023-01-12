//
//  ViewController.swift
//  RudderSampleAppOneTrustConsent
//
//  Created by Pallab Maiti on 12/01/23.
//

import UIKit
import OTPublishersHeadlessSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        OTPublishersHeadlessSDK.shared.setupUI(self, UIType: .preferenceCenter)
        
        let domainData = OTPublishersHeadlessSDK.shared.getDomainGroupData()
        let groups = domainData?["Groups"]
        let commonData = OTPublishersHeadlessSDK.shared.getCommonData()
        let domainInfo = OTPublishersHeadlessSDK.shared.getDomainInfo()
        
        let bannerData = OTPublishersHeadlessSDK.shared.getBannerData()
        let getPreferenceCenterData = OTPublishersHeadlessSDK.shared.getPreferenceCenterData()
        
        print(domainData)
        print(groups)
        print(commonData)
        print(domainInfo)
    }


}

