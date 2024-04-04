//
//  CoreMocks.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 24/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import RudderInternal
@testable import Rudder

extension Configuration {
    static func mockAny() -> Configuration {
        .mockWith()
    }
    
    static func mockWith(
        writeKey: String = .mockRandom(among: .alphanumerics, length: 27),
        dataPlaneURL: String = .mockAnyURL(),
        flushQueueSize: Int = .mockRandom(min: Constants.queueSize.min, max: Constants.queueSize.max),
        dbCountThreshold: Int = .mockRandom(),
        sleepTimeOut: Int = .mockRandom(),
        logLevel: LogLevel = .debug,
        trackLifecycleEvents: Bool = .random(),
        controlPlaneURL: String = .mockAnyURL(),
        autoSessionTracking: Bool = .random(),
        sessionTimeOut: Int = .mockRandom(),
        gzipEnabled: Bool = .random(),
        flushPolicies: [FlushPolicy] = [FlushPolicy](),
        dataUploadRetryPolicy: RetryPolicy? = nil,
        sourceConfigDownloadRetryPolicy: RetryPolicy? = nil,
        logger: LoggerProtocol? = NOLogger(),
        dataResidencyServer: DataResidencyServer = Constants.residencyServer.default
    ) -> Configuration {
        .init(writeKey: writeKey, dataPlaneURL: dataPlaneURL)!
        .flushQueueSize(flushQueueSize)
        .dbCountThreshold(dbCountThreshold)
        .sleepTimeOut(sleepTimeOut)
        .logLevel(logLevel)
        .trackLifecycleEvents(trackLifecycleEvents)
        .controlPlaneURL(controlPlaneURL)
        .autoSessionTracking(autoSessionTracking)
        .sessionTimeOut(sessionTimeOut)
        .gzipEnabled(gzipEnabled)
        .flushPolicies(flushPolicies)
        .dataUploadRetryPolicy(dataUploadRetryPolicy)
        .sourceConfigDownloadRetryPolicy(sourceConfigDownloadRetryPolicy)
        .logger(logger)
        .dataResidencyServer(dataResidencyServer)
    }
}

class DataUploaderMock: DataUploaderType {
    let uploadStatus: APIStatus
    
    var onUpload: (() -> Void)?
    
    private(set) var uploadedMessages: [StorageMessage] = []
    
    init(uploadStatus: APIStatus, onUpload: (() -> Void)? = nil) {
        self.uploadStatus = uploadStatus
        self.onUpload = onUpload
    }
    
    func upload(messages: [StorageMessage]) -> APIStatus {
        uploadedMessages += messages
        onUpload?()
        return uploadStatus
    }
}

class SourceConfigDownloaderMock: SourceConfigDownloaderType {
    let downloadStatus: APIStatus
    var onDownload: (() -> Void)?
    let sourceConfig: SourceConfig?
    
    init(downloadStatus: APIStatus, onDownload: (() -> Void)? = nil, sourceConfig: SourceConfig? = nil) {
        self.downloadStatus = downloadStatus
        self.onDownload = onDownload
        self.sourceConfig = sourceConfig
    }
    
    func download() -> SourceConfigDownloadResponse {
        onDownload?()
        return SourceConfigDownloadResponse(
            sourceConfig: sourceConfig,
            status: downloadStatus
        )
    }
}

extension APIStatus: RandomMockable {
    public static func mockRandom() -> APIStatus {
        .init(needsRetry: .random(), responseCode: .mockRandom(min: 200, max: 500), error: nil)
    }
    
    public static func mockWith(
        needsRetry: Bool = .mockAny(),
        responseCode: Int = .mockAny(),
        error: APIError? = nil
    ) -> APIStatus {
        .init(needsRetry: needsRetry, responseCode: responseCode, error: error)
    }
}

extension APIStatus {
    init(httpResponse: HTTPURLResponse) {
        self.init(responseStatusCode: httpResponse.statusCode)
    }
}

class AlwaysBlockersMock: DownloadUploadBlockersProtocol {
    func get() -> [Blocker] {
        [.networkReachability(description: "Always Block")]
    }
}

class NoBlockersMock: DownloadUploadBlockersProtocol {
    func get() -> [Blocker] {
        []
    }
}

extension DownloadUploadRetryPreset {    
    static var noOp = DownloadUploadRetryPreset(
        retries: .max,
        maxTimeout: .distantFuture,
        minTimeout: .distantFuture,
        factor: .max
    )
}

class RetryPolicyMock: RetryPolicy {
    var retryPreset: RetryPreset
    var current: TimeInterval
    let retry: Bool
    var retryFactors: RetryFactors
    
    init(retryFactors: RetryFactors, retry: Bool) {
        self.retryFactors = retryFactors
        self.retryPreset = retryFactors.retryPreset
        self.current = retryFactors.current
        self.retry = retry
    }
    
    func increase() {
        current = TimeInterval(1)
    }
    
    func reset() {
        current = retryFactors.current
    }
    
    func shouldRetry() -> Bool {
        retry
    }
}

extension RetryFactors {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        retryPreset: RetryPreset = DownloadUploadRetryPreset.mockAny(),
        current: TimeInterval = TimeInterval(.mockRandom())
    ) -> Self {
        .init(retryPreset: retryPreset, current: current)
    }
}

extension DownloadUploadRetryPreset {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        retries: Int = .mockRandom(),
        maxTimeout: TimeInterval = TimeInterval(.mockRandom()),
        minTimeout: TimeInterval = TimeInterval(.mockRandom()),
        factor: Int = .mockRandom()
    ) -> Self {
        .init(retries: retries, maxTimeout: maxTimeout, minTimeout: minTimeout, factor: factor)
    }
}

public struct ErrorMock: Error, CustomStringConvertible {
    public let description: String
    
    public init(_ description: String = "") {
        self.description = description
    }
}

extension StorageMessage {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        id: String = .mockRandom(among: .alphanumerics, length: 32),
        message: String = .mockRandom(length: 20),
        updated: Int = .mockRandom(max: 10)
    ) -> Self {
        .init(id: id, message: message, updated: updated)
    }
}

class UserDefaultsWorkerMock: UserDefaultsWorkerProtocol {
    var value: Codable?
    let queue: DispatchQueue
    
    init(value: Codable? = nil, queue: DispatchQueue) {
        self.value = value
        self.queue = queue
    }
    
    func write<T>(_ key: Rudder.UserDefaultsKeys, value: T?) where T : Decodable, T : Encodable {
        queue.sync {
            self.value = value
        }
    }
    
    func read<T>(_ key: Rudder.UserDefaultsKeys) -> T? where T : Decodable, T : Encodable {
        queue.sync {
            return self.value as? T
        }
    }
    
    func remove(_ key: Rudder.UserDefaultsKeys) {
        queue.sync {
            self.value = nil
        }
    }
}

class URLProtocolMock: URLProtocol {
    var serverMock: ServerMock?
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        serverMock = ServerMock.instance
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let response = serverMock?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = serverMock?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let error = serverMock?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
}

class ServerMock {
    let response: HTTPURLResponse?
    let data: Data?
    let error: NSError?
    static var instance: ServerMock?
    
    enum ServerResult {
        case success(response: HTTPURLResponse, data: Data = .mockAny())
        case failure(error: NSError)
    }
    
    init(serverResult: ServerResult) {
        switch serverResult {
        case .success(let response, let data):
            self.response = response
            self.data = data
            self.error = nil
        case .failure(let error):
            self.response = nil
            self.data = nil
            self.error = error
        }
        Self.instance = self
    }
    
    func getInterceptedURLSession(delegate: URLSessionDelegate? = nil) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}

extension SQLiteStorage {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        path: URL = FileManager.default.urls(for: .cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0],
        name: String = .mockRandom(),
        logger: LoggerProtocol = NOLogger()
    ) -> Self {
        let path = path
        let database = SQLiteDatabase(path: path, name: "\(name).sqlite")
        return self.init(database: database, logger: Logger(logger: logger))
    }
}

extension RSClient {
    static func mockAny() -> RSClient {
        .mockWith()
    }
    
    static func mockWith(
        configuration: Configuration = .mockAny(),
        instanceName: String = RudderRegistry.defaultInstanceName,
        database: Database? = SQLiteDatabaseMock(),
        storage: Storage? = StorageMock(),
        userDefaults: UserDefaults? = UserDefaults(suiteName: #file),
        apiClient: APIClient? = URLSessionClient(session: .shared),
        sourceConfigDownloader: SourceConfigDownloaderType? = SourceConfigDownloaderMock(downloadStatus: .mockWith(responseCode: 200)),
        dataUploader: DataUploaderType? = DataUploaderMock(uploadStatus: .mockWith(responseCode: 200))
    ) -> RSClient {
        return initialize(
            with: configuration,
            instanceName: instanceName,
            database: database,
            storage: storage,
            userDefaults: userDefaults,
            apiClient: apiClient,
            sourceConfigDownloader: sourceConfigDownloader,
            dataUploader: dataUploader
        )
    }
}

class StorageMigratorMock: StorageMigrator {
    var currentStorage: Storage = StorageMock()
    
    func migrate() {
        
    }
}
