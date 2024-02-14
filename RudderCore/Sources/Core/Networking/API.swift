//
//  API.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

enum API {
    case flushBatch(params: String, anonymousId: String, gzipEnabled: Bool, dataPlaneUrl: String)
    case downloadSourceConfig(controlPlaneUrl: String)
}

extension API {
    var version: String {
        return "v1"
    }

    var headers: [String: String]? {
        var fields = ["Content-Type": "Application/json"]
        switch self {
        case .flushBatch(_, let anonymousId, let gzipEnabled, _):
            fields["AnonymousId"] = anonymousId
            if gzipEnabled {
                fields["Content-Encoding"] = "gzip"
            }
        case .downloadSourceConfig:
            break
        }
        return fields
    }
    
    var baseURL: String {
        switch self {
        case .flushBatch(_, _, _, let dataPlaneUrl):
            return dataPlaneUrl.rectified + version
        case .downloadSourceConfig(let controlPlaneUrl):
            return controlPlaneUrl.rectified
        }
    }
    
    var httpBody: Data? {
        switch self {
        case .flushBatch(let params, _, let gzipEnabled, _):
            var data = params.data(using: .utf8)
            if gzipEnabled {
                data = try? data?.gzipped()
            }
            return data
        case .downloadSourceConfig:
            return nil
        }
    }
    
    var method: Method {
        switch self {
        case .downloadSourceConfig:
            return .get
        case .flushBatch:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .flushBatch:
            return "/batch"
        case .downloadSourceConfig:
            return "sourceConfig?p=ios&v=\(RSVersion)"
        }
    }
    
    var url: URL {
        URL(string: [baseURL, path].joined().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")!
    }
    
    func request(writeKey: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.value
        if let authToken = writeKey.computeAuthToken() {
            request.allHTTPHeaderFields?["Authorization"] = "Basic \(authToken)"
        }
        if let headers = headers {
            for (key, value) in headers {
                request.allHTTPHeaderFields?[key] = value
            }
        }
        request.httpBody = httpBody
        return request
    }
}

enum Method {
    case post
    case get
    case put
    case delete
    
    var value: String {
        switch self {
        case .post:
            return "POST"
        case .get:
            return "GET"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
}
