//
//  NetworkManagerTests.swift
//  Rudder
//
//  Created by Satheesh Kannan on 21/08/26.
//

import XCTest
@testable import Rudder

class NetworkManagerTests: XCTestCase {

    private static let dummyHost = "dummy.dataplane.rudderstack.com"

    var networkManager: RSNetworkManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        #if os(watchOS)
        // URLSession on watchOS does not consult custom URLProtocol classes,
        // so the stub below cannot intercept requests there.
        throw XCTSkip("Custom URLProtocol stubs are not supported on watchOS")
        #endif
        URLProtocol.registerClass(StubURLProtocol.self)
        networkManager = NetworkManagerTests.makeNetworkManager(authToken: "dummyAuthToken")
    }

    override func tearDown() {
        URLProtocol.unregisterClass(StubURLProtocol.self)
        StubURLProtocol.reset()
        networkManager = nil
        super.tearDown()
    }

    private static func makeNetworkManager(authToken: String) -> RSNetworkManager {
        let config = RSConfigBuilder()
            .withDataPlaneUrl("https://\(dummyHost)")
            .build()
        let dataResidencyManager = RSDataResidencyManager(rsConfig: config)
        return RSNetworkManager(config: config, andAuthToken: authToken, andAnonymousIdToken: "dummyAnonymousIdToken", andDataResidencyManager: dataResidencyManager)
    }

    // sendNetworkRequest blocks the calling thread on a semaphore, so run it
    // off the test thread; a nil return means it never came back in time.
    private func sendRequest(using manager: RSNetworkManager? = nil, timeout: TimeInterval = 10) -> RSNetworkResponse? {
        let manager = manager ?? networkManager!
        var response: RSNetworkResponse?
        let exp = expectation(description: "sendNetworkRequest returned")
        DispatchQueue.global().async {
            response = manager.sendNetworkRequest("{}", to: BATCH_ENDPOINT, withRequest: POST)
            exp.fulfill()
        }
        wait(for: [exp], timeout: timeout)
        return response
    }

    // MARK: - Offline deadlock regression

    // Regression for the offline upload deadlock: the completion handler must
    // signal the semaphore on the NSURLErrorNotConnectedToInternet path, or
    // sendNetworkRequest never returns and networkLock is held forever.
    func testSendNetworkRequestReturnsWhenOffline() {
        StubURLProtocol.failWith(NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet))
        let response = sendRequest()
        XCTAssertNotNil(response)
        XCTAssertEqual(response?.state, NETWORK_UNAVAILABLE)
    }

    // A request attempted while offline must not wedge networkLock: a
    // subsequent request has to run and return as well.
    func testSubsequentRequestRunsAfterOfflineFailure() {
        StubURLProtocol.failWith(NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet))
        XCTAssertEqual(sendRequest()?.state, NETWORK_UNAVAILABLE)
        XCTAssertEqual(sendRequest()?.state, NETWORK_UNAVAILABLE)
    }

    // Other transport errors (timeout, connection lost, ...) flow through the
    // response-parsing branch and must classify as a retryable NETWORK_ERROR,
    // never terminate the caller or hang.
    func testTimeoutClassifiesAsNetworkError() {
        StubURLProtocol.failWith(NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut))
        let response = sendRequest()
        XCTAssertNotNil(response)
        XCTAssertEqual(response?.state, NETWORK_ERROR)
    }

    // MARK: - Response classification

    func testSuccessResponse() {
        StubURLProtocol.respondWith(statusCode: 200, body: "{\"ok\":true}")
        let response = sendRequest()
        XCTAssertEqual(response?.state, NETWORK_SUCCESS)
        XCTAssertEqual(response?.statusCode, 200)
        XCTAssertEqual(response?.responsePayload, "{\"ok\":true}")
        XCTAssertNil(response?.errorPayload)
    }

    func testResourceNotFoundResponse() {
        StubURLProtocol.respondWith(statusCode: 404, body: "not found")
        XCTAssertEqual(sendRequest()?.state, RESOURCE_NOT_FOUND)
    }

    func testBadRequestResponse() {
        StubURLProtocol.respondWith(statusCode: 400, body: "bad request")
        XCTAssertEqual(sendRequest()?.state, BAD_REQUEST)
    }

    func testInvalidWriteKeyResponse() {
        StubURLProtocol.respondWith(statusCode: 401, body: "Invalid write key")
        XCTAssertEqual(sendRequest()?.state, WRONG_WRITE_KEY)
    }

    func testServerErrorClassifiesAsNetworkError() {
        StubURLProtocol.respondWith(statusCode: 500, body: "internal server error")
        let response = sendRequest()
        XCTAssertEqual(response?.state, NETWORK_ERROR)
        XCTAssertEqual(response?.statusCode, 500)
        XCTAssertEqual(response?.errorPayload, "internal server error")
    }

    // MARK: - Early returns

    // An empty auth token must abort before any network work.
    func testEmptyAuthTokenAbortsRequest() {
        let manager = NetworkManagerTests.makeNetworkManager(authToken: "")
        let response = sendRequest(using: manager)
        XCTAssertEqual(response?.state, WRONG_WRITE_KEY)
    }
}

// Serves a canned reply for requests to the dummy data plane, without touching
// the network: either a transport-level failure or an HTTP response with a
// status code and body. Registered against the shared session, which is what
// RSNetworkManager uses.
final class StubURLProtocol: URLProtocol {

    private static var stubError: NSError?
    private static var stubStatusCode: Int = 200
    private static var stubBody: String?

    static func failWith(_ error: NSError) {
        stubError = error
        stubBody = nil
    }

    static func respondWith(statusCode: Int, body: String?) {
        stubError = nil
        stubStatusCode = statusCode
        stubBody = body
    }

    static func reset() {
        stubError = nil
        stubStatusCode = 200
        stubBody = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.host == "dummy.dataplane.rudderstack.com"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = StubURLProtocol.stubError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        let response = HTTPURLResponse(url: request.url!, statusCode: StubURLProtocol.stubStatusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let body = StubURLProtocol.stubBody, let data = body.data(using: .utf8) {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
}
