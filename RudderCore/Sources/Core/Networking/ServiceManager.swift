//
//  ServiceManager.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol ServiceType {
    func downloadSourceConfig(controlPlaneUrl: String, _ completion: @escaping Handler<APIResponse<SourceConfig>>)
    
    func flushBatch(params: String, anonymousId: String, gzipEnabled: Bool, dataPlaneUrl: String, _ completion: @escaping Handler<APIResponse<Bool>>)
}

public typealias Handler<T> = (Result<T, Error>) -> Void

struct ServiceManager: ServiceType {
    let apiClient: APIClient
    let writeKey: String
    
    init(apiClient: APIClient, writeKey: String) {
        self.apiClient = apiClient
        self.writeKey = writeKey
    }
    
    func downloadSourceConfig(controlPlaneUrl: String, _ completion: @escaping Handler<APIResponse<SourceConfig>>) {
        request(.downloadSourceConfig(controlPlaneUrl: controlPlaneUrl)) { result in
            switch result {
            case .success(let response):
                do {
                    if let data = response.data {
                        let sourceConfig = try JSONDecoder().decode(SourceConfig.self, from: data)
                        completion(.success(APIResponse(value: sourceConfig, statusCode: response.urlResponse.statusCode)))
                    } else {
                        completion(.failure(APIError.httpError(statusCode: response.urlResponse.statusCode)))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func flushBatch(params: String, anonymousId: String, gzipEnabled: Bool, dataPlaneUrl: String, _ completion: @escaping Handler<APIResponse<Bool>>) {
        request(.flushBatch(params: params, anonymousId: anonymousId, gzipEnabled: gzipEnabled, dataPlaneUrl: dataPlaneUrl)) { result in
            switch result {
            case .success(let response):
                completion(.success(APIResponse(value: true, statusCode: response.urlResponse.statusCode)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension ServiceManager {
    func request(_ api: API, _ completion: @escaping Handler<APIURLResponse>) {
        apiClient.send(request: api.request(writeKey: writeKey)) { result in
            switch result {
            case .success(let response):
                if response.isSuccess {
                    completion(.success(response))
                } else {
                    completion(.failure(APIError.httpError(statusCode: response.urlResponse.statusCode)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension APIURLResponse {
    var isSuccess: Bool {
        return 200..<300 ~= urlResponse.statusCode
    }
}
