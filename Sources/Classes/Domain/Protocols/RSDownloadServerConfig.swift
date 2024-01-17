//
//  RSDownloadServerConfig.swift
//  Rudder
//
//  Created by Pallab Maiti on 10/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

protocol RSDownloadServerConfig {
    func downloadServerConfig(retryCount: Int, completion: @escaping (RSServerConfig?) -> Void)
}

class RSDownloadServerConfigImpl: RSDownloadServerConfig {
    
    let serviceManager: RSServiceType?
    
    init(serviceManager: RSServiceType?) {
        self.serviceManager = serviceManager
    }
    
    func downloadServerConfig(retryCount: Int, completion: @escaping (RSServerConfig?) -> Void) {
        let maxRetryCount = 4
        
        guard retryCount < maxRetryCount else {
            Logger.log(message: "Server config download failed.", logLevel: .debug)
            completion(nil)
            return
        }
        
        serviceManager?.downloadServerConfig({ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let serverConfig):
                completion(serverConfig)
            case .failure(let error):
                if error.code == RSErrorCode.WRONG_WRITE_KEY.rawValue {
                    Logger.log(message: "Wrong write key", logLevel: .error)
                    self.downloadServerConfig(retryCount: maxRetryCount, completion: completion)
                } else {
                    Logger.log(message: "Retrying download in \(retryCount) seconds", logLevel: .debug)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(retryCount)) {
                        self.downloadServerConfig(retryCount: retryCount + 1, completion: completion)
                    }
                }
            }
        })
    }
}
