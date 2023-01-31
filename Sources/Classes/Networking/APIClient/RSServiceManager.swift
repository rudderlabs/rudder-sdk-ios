//
//  RSServiceManager.swift
//  RudderStack
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

typealias Handler<T> = (HandlerResult<T, NSError>) -> Void

enum HandlerResult<Success, Failure> {
    case success(Success)
    case failure(Failure)
}

struct RSServiceManager: RSServiceType {
    static let sharedSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: configuration)
    }()
    
    let client: RSClient
    
    var version: String {
        return "v1"
    }
    
    init(client: RSClient) {
        self.client = client
    }
    
    func downloadServerConfig(_ completion: @escaping Handler<RSServerConfig>) {
        request(.downloadConfig, completion)
    }
    
    func flushEvents(params: String, _ completion: @escaping Handler<Bool>) {
        request(.flushEvents(params: params), completion)
    }
}

extension RSServiceManager {
    func request<T: Codable>(_ API: API, _ completion: @escaping Handler<T>) {
        let urlString = [baseURL(API), path(API)].joined().addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        client.log(message: "URL: \(urlString ?? "")", logLevel: .debug)
        var request = URLRequest(url: URL(string: urlString ?? "")!)
        request.httpMethod = method(API).value
        if let headers = headers(API) {
            request.allHTTPHeaderFields = headers
            client.log(message: "HTTPHeaderFields: \(headers)", logLevel: .debug)
        }
        if let httpBody = httpBody(API) {
            request.httpBody = httpBody
            client.log(message: "HTTPBody: \(httpBody)", logLevel: .debug)
        }
        let dataTask = RSServiceManager.sharedSession.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                completion(.failure(NSError(code: .SERVER_ERROR)))
                return
            }
            let response = response as? HTTPURLResponse
            if let statusCode = response?.statusCode {
                let apiClientStatus = APIClientStatus(statusCode)
                switch apiClientStatus {
                case .success:
                    switch API {
                    case .flushEvents:
                        completion(.success(true as! T)) // swiftlint:disable:this force_cast
                    default:
                        do {
                            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                                client.log(message: jsonString, logLevel: .debug)
                            }
                            let object = try JSONDecoder().decode(T.self, from: data ?? Data())
                            completion(.success(object))
                        } catch {
                            completion(.failure(NSError(code: .DECODING_FAILED)))
                        }
                    }
                default:
                    let errorCode = handleCustomError(data: data ?? Data())
                    completion(.failure(NSError(code: errorCode)))
                }
            } else {
                completion(.failure(NSError(code: .SERVER_ERROR)))
            }
        })
        dataTask.resume()
    }
    
    func handleCustomError(data: Data) -> RSErrorCode {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else {
                return .SERVER_ERROR
            }
            if let message = json["message"], message == "Invalid write key" {
                return .WRONG_WRITE_KEY
            }
            return .SERVER_ERROR
        } catch {
            return .SERVER_ERROR
        }
    }
}

extension RSServiceManager {
    func headers(_ API: API) -> [String: String]? {
        var headers = ["Content-Type": "Application/json",
                       "Authorization": "Basic \(client.config?.writeKey.computeAuthToken() ?? "")"]
        switch API {
        case .flushEvents:
            if let anonymousIdPlugin = client.find(pluginType: RSAnonymousIdPlugin.self) {
                headers["AnonymousId"] = anonymousIdPlugin.anonymousId?.computeAnonymousIdToken() ?? ""
            }            
        default:
            break
        }
        return headers
    }
    
    func baseURL(_ API: API) -> String {
        switch API {
        case .flushEvents:
            return "\(client.config?.dataPlaneUrl ?? RSDataPlaneUrl)/\(version)/"
        case .downloadConfig:
            if client.config?.controlPlaneUrl.hasSuffix("/") == true {
                return "\(client.config?.controlPlaneUrl ?? RSControlPlaneUrl)"
            } else {
                return "\(client.config?.controlPlaneUrl ?? RSControlPlaneUrl)/"
            }
        }
    }
    
    func httpBody(_ API: API) -> Data? {
        switch API {
        case .flushEvents(let params):
            return params.data(using: .utf8)
        case .downloadConfig:
            return nil
        }
    }
    
    func method(_ API: API) -> Method {
        switch API {
        case .downloadConfig:
            return .get
        default:
            return .post
        }
    }
    
    func path(_ API: API) -> String {
        switch API {
        case .flushEvents:
            return "batch"
        case .downloadConfig:
            return "sourceConfig?p=ios&v=\(RSVersion)"
        }
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
