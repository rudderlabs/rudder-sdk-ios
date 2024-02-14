//
//  APIStatus.swift
//  Rudder
//
//  Created by Pallab Maiti on 15/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public struct APIStatus: Equatable {
    let needsRetry: Bool
    let responseCode: Int?
    let error: APIError?
    
    public init(needsRetry: Bool, responseCode: Int?, error: APIError?) {
        self.needsRetry = needsRetry
        self.responseCode = responseCode
        self.error = error
    }
    
    public init(error: Error) {
        self.needsRetry = true
        if let err = error as? APIError {
            self.error = err
            if case let .httpError(statusCode) = err {
                self.responseCode = statusCode
            } else {
                self.responseCode = nil
            }
        } else {
            self.error = APIError.networkError(error: error as NSError)
            self.responseCode = nil
        }
    }
    
    public init(responseStatusCode: Int) {
        let statusCode: APIResponseStatusCode = APIResponseStatusCode(rawValue: responseStatusCode) 
        self.needsRetry = statusCode.needsRetry
        self.responseCode = responseStatusCode
        self.error = APIError(statusCode: responseStatusCode)
    }
}

enum APIResponseStatusCode {
    case success
    case failure
    case serverFailure
    case unknown
    case unauthorized
    
    init(rawValue: Int) {
        switch rawValue {
        case 200..<300:
            self = .success
        case 400..<402:
            self = .unauthorized
        case 402..<500:
            self = .failure
        case 500..<600:
            self = .serverFailure
        default:
            self = .unknown
        }
    }
    
    var needsRetry: Bool {
        switch self {
        case .success, .unauthorized:
            return false
        default:
            return true
        }
    }
}

public enum APIError: Error, Equatable {
    case httpError(statusCode: Int)
    case networkError(error: NSError)
    case noResponse
    
    init?(statusCode: Int) {
        guard 200..<300 ~= statusCode else {
            self = .httpError(statusCode: statusCode)
            return
        }
        return nil
    }
}

public struct APIURLResponse {
    let data: Data?
    let urlResponse: HTTPURLResponse
    
    init(data: Data?, urlResponse: HTTPURLResponse) {
        self.data = data
        self.urlResponse = urlResponse
    }
}

public struct APIResponse<T: Any> {
    let value: T
    let statusCode: Int
}
