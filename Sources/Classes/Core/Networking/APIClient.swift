//
//  APIClient.swift
//  Rudder
//
//  Created by Pallab Maiti on 25/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol APIClient {
    func send(request: URLRequest, _ completion: @escaping Handler<APIURLResponse>)
}

class URLSessionClient: APIClient {
    static let sharedSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: configuration)
    }()
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func send(request: URLRequest, _ completion: @escaping Handler<APIURLResponse>) {
        let task = session.dataTask(with: request) { data, response, error in
            completion(Self.apiClientResult(for: (data, response, error)))
        }
        task.resume()
    }
    
    // swiftlint:disable large_tuple
    private static func apiClientResult(for urlSessionTaskCompletion: (Data?, URLResponse?, Error?)) -> Result<APIURLResponse, Error> {
        let (data, response, error) = urlSessionTaskCompletion
        
        if let error = error {
            return .failure(error)
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            return .success(APIURLResponse(data: data, urlResponse: httpResponse))
        }
        
        return .failure(APIError.noResponse)
    }
}

extension URLSession {
    static func defaultSession() -> Self {
        let configuration: URLSessionConfiguration = .default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return .init(configuration: configuration)
    }
}
