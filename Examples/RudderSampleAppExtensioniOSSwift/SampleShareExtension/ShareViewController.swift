//
//  ShareViewController.swift
//  SampleShareExtension
//
//  Created by Desu Sai Venkat on 14/11/23.
//

import UIKit
import Social
import MobileCoreServices
import Rudder

enum Event : String, CaseIterable {
    case identify = "Identify"
    case track = "Track"
    case screen = "Screen"
}

class ShareViewController: SLComposeServiceViewController {
    
    fileprivate var selectedEvent: Event?
    
    override func presentationAnimationDidFinish() {
        // todo
        print("animation finished")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Override point for customization after application launch.
        guard let path = Bundle.main.path(forResource: "RudderConfig", ofType: "plist"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let rudderConfig = try? PropertyListDecoder().decode(RudderConfig.self, from: data) else {
            return
        }
        
        selectedEvent = .track
        setURLAsContent()
        let builder: RSConfigBuilder = RSConfigBuilder()
            .withLoglevel(RSLogLevelDebug)
            .withDataPlaneUrl(rudderConfig.PROD_DATA_PLANE_URL)
        RSClient.getInstance(rudderConfig.WRITE_KEY, config: builder.build())
        RSClient.getInstance().track("App Extension Loaded")
        print("view loaded")
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    func logErrorAndCompleteRequest(error: Error?) {
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    
    private func setURLAsContent() {
            guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { self.logErrorAndCompleteRequest(error: nil); return }
            if items.count == 0 { self.logErrorAndCompleteRequest(error: nil); return }
            for item in items {
                guard let attachments = item.attachments else { continue }
                for attachment in attachments {
                    if attachment.hasItemConformingToTypeIdentifier("public.data") {
                        attachment.loadItem(forTypeIdentifier: "public.data", options: nil, completionHandler: { (decoder, error) in
                            if error != nil { self.logErrorAndCompleteRequest(error: error); return }
                            guard let dictionary = decoder as? NSDictionary else {
                                self.logErrorAndCompleteRequest(error: error); return }
                            guard let results = dictionary.value(forKey: NSExtensionJavaScriptPreprocessingResultsKey) as? NSDictionary else {
                                self.logErrorAndCompleteRequest(error: error); return }
                            OperationQueue.main.addOperation {
                                self.textView.text = results.value(forKey: "URL") as? String
                            }
                        })
                    } else {
                        self.logErrorAndCompleteRequest(error: nil)
                    }
                }
            }
        }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        switch selectedEvent {
        case .identify:
            RSClient.getInstance().identify("testUserId")
        case .screen:
            RSClient.getInstance().screen("Home Screen", properties: ["url": self.contentText!])
        case .track:
            RSClient.getInstance().track("Sharing URL", properties: ["url": self.contentText!])
        default:
            print("unsupported event")
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func didSelectCancel() {
        print("did select cancel")
        self.extensionContext!.cancelRequest(withError: NSError(domain: "Cancelled Error", code: NSUserCancelledError))
    }

    override func configurationItems() -> [Any]! {
        if let configurationItem = SLComposeSheetConfigurationItem() {
                    configurationItem.title = "Selected Event"
            configurationItem.value = selectedEvent?.rawValue
                    configurationItem.tapHandler = {
                        let vc = ShareSelectViewController()
                        vc.delegate = self
                        self.pushConfigurationViewController(vc)
                    }
                    return [configurationItem]
                }
                return nil
    }
}

extension ShareViewController: ShareSelectViewControllerDelegate {
    func selected(event: Event) {
        selectedEvent = event
        reloadConfigurationItems()
        popConfigurationViewController()
    }
}
