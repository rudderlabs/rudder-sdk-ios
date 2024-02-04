//
//  APIClientMock.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 25/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
@testable import Rudder

class APIClientMock: APIClient {
    let result: (URLRequest) -> Result<HTTPURLResponse, Error>
    let data: Data?
    var requests: [URLRequest] = []
    let queue = DispatchQueue(label: "com.rudder.APIClientMock.\(UUID().uuidString)")
    
    init(result: @escaping ((URLRequest) -> Result<HTTPURLResponse, Error>) = { _  in .success(.mockResponseWith(statusCode: 200))}, data: Data? = nil) {
        self.result = result
        self.data = data
    }
    
    convenience init(response: HTTPURLResponse, data: Data? = nil) {
        self.init(result: { _ in .success(response) }, data: data)
    }
    
    convenience init(error: Error, data: Data? = nil) {
        self.init(result: { _ in .failure(error) }, data: data)
    }
    
    func send(request: URLRequest, _ completion: @escaping Handler<APIURLResponse>) {
        queue.async {
            switch self.result(request) {
            case .success(let response):
                completion(.success(APIURLResponse(data: self.data, urlResponse: response)))
            case .failure(let error):
                completion(.failure(error))
            }
            self.requests.append(request)
        }
    }
}
