//
//  DefaultsPersistenceTests.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 31/01/24.
//

import XCTest
import Foundation
@testable import Rudder


class DefaultsPersistenceTests: XCTestCase {
    
    override func setUp() {
        clearDefaults()
        RSDefaultsPersistence.sharedInstance().clearState()
        super.setUp()
    }
    
    override func tearDown() {
        clearDefaults()
        RSDefaultsPersistence.sharedInstance().clearState()
        super.tearDown()
    }
    
    func testCopyingFromStandardDefaultsIfNeeded() {
        UserDefaults.standard.setValue("{\"name\": \"John\"}", forKey: RSTraitsKey)
        UserDefaults.standard.setValue(false, forKey: RSOptStatus)
        UserDefaults.standard.setValue("1.4.4", forKey: RSApplicationInfoKey)
        UserDefaults.standard.setValue(1706686541, forKey: RSLastActiveTimestamp)
        UserDefaults.standard.setValue("RudderStack India", forKey: "Company")
        
        let defaultsPersistence = RSDefaultsPersistence.sharedInstance()
        defaultsPersistence?.clearState()
        defaultsPersistence?.copyStandardDefaultsToPersistenceIfNeeded()
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSTraitsKey) as? String, "{\"name\": \"John\"}")
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSOptStatus) as? Bool, false)
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSApplicationInfoKey) as? String, "1.4.4")
        XCTAssertNil(defaultsPersistence?.readObject(forKey: "Company"))
        XCTAssertEqual(defaultsPersistence?.readObject(forKey: RSLastActiveTimestamp) as? Int, 1706686541)
    }
    
    func testIfFallingBackToPersistenceLayer() {
        
        let preferenceManager = RSPreferenceManager.getInstance()
        preferenceManager.saveTraits("{\"name\": \"Adam\"}")
        preferenceManager.saveOptStatus(false)
        preferenceManager.saveBuildVersionCode("1.4.5")
        preferenceManager.saveLastActiveTimestamp(1706686542)
        
        XCTAssertEqual(preferenceManager.getTraits() as String, "{\"name\": \"Adam\"}")
        
        // now simulate that the app developer directly clears the standard defaults
        // and check if the preference manager is falling back to persistence layer
        clearDefaults()
        XCTAssertEqual(preferenceManager.getTraits() as String, "{\"name\": \"Adam\"}")
        XCTAssertEqual(preferenceManager.getOptStatus(), false)
        XCTAssertEqual(preferenceManager.getBuildVersionCode(), "1.4.5")
        XCTAssertEqual(preferenceManager.getLastActiveTimestamp(), 1706686542)
    }
    
    func testRestoringDefaultsFromPersistence() {
        let preferenceManager = RSPreferenceManager.getInstance()
        preferenceManager.saveTraits("{\"name\": \"David\"}")
        preferenceManager.saveOptStatus(true)
        preferenceManager.saveBuildVersionCode("1.4.6")
        preferenceManager.saveLastActiveTimestamp(1706686543)
        
        XCTAssertEqual(preferenceManager.getTraits() as String, "{\"name\": \"David\"}")
        
        clearDefaults()
        
        // preference manager would return back the values from persistence layer and will also set the value in user defaults
        XCTAssertEqual(preferenceManager.getTraits() as String, "{\"name\": \"David\"}")
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSTraitsKey) as? String, "{\"name\": \"David\"}")
        XCTAssertEqual(preferenceManager.getOptStatus(), true)
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSOptStatus) as? Bool, true)
        XCTAssertEqual(preferenceManager.getBuildVersionCode(), "1.4.6")
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSApplicationInfoKey) as? String, "1.4.6")
        XCTAssertEqual(preferenceManager.getLastActiveTimestamp(), 1706686543)
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSLastActiveTimestamp) as? Int, 1706686543)
        
        clearDefaults()
        
        // now we are restoring the missing keys to defaults from persistence, post which defaults should contain the values
        preferenceManager.restoreMissingDefaultsFromPersistence()
        
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSTraitsKey) as? String, "{\"name\": \"David\"}")
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSOptStatus) as? Bool, true)
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSApplicationInfoKey) as? String, "1.4.6")
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSLastActiveTimestamp) as? Int, 1706686543)
    }
    
    func clearDefaults() {
        for key in [RSTraitsKey, RSOptStatus, RSApplicationInfoKey, RSLastActiveTimestamp, "Company"] {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    // MARK: - SDK-5186 persistence-fix tests: async writes stay read-after-write consistent, do not
    // block the calling thread, and flush to disk on app background/terminate.

    /// Async writes must stay read-after-write consistent — the serial FIFO queue guarantees a read
    /// enqueued after a write sees it. This is the safety property that lets the writes be async.
    func test_fix_readAfterWrite_consistent() {
        let p = RSDefaultsPersistence.sharedInstance()!
        p.write("v1", forKey: "rl_raw")
        XCTAssertEqual(p.readObject(forKey: "rl_raw") as? String, "v1")
        p.write("v2", forKey: "rl_raw")
        XCTAssertEqual(p.readObject(forKey: "rl_raw") as? String, "v2")
    }

    /// Writes must no longer block the calling (main) thread. With the old `dispatch_sync`, each of
    /// these 100 calls would synchronously rewrite the whole ~2MB plist on the main thread (seconds in
    /// aggregate). Async makes each call a near-instant enqueue. The 0.5s ceiling leaves a large margin
    /// over the real cost (~ms) while still failing loudly if writes ever go back to blocking on I/O.
    func test_fix_writeObject_doesNotBlockMainThread() {
        let p = RSDefaultsPersistence.sharedInstance()!
        let big = String(repeating: "x", count: 2_000_000) // ~2MB → a sync full-file write is expensive
        p.write(big, forKey: "rl_big")
        XCTAssertTrue(Thread.isMainThread)
        let start = Date()
        for i in 0..<100 { p.write("val-\(i)", forKey: "rl_big") }
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertLessThan(elapsed, 0.5, "100 main-thread writes took \(elapsed)s — writes are blocking on disk I/O")
    }

    /// THE FIX (lifecycle net). Posting the terminate notification must synchronously drain the write
    /// queue to disk (`flushToDisk:` → `writeToFileSync`). We read the plist FILE directly with NO
    /// sleep: `writeToFileSync` does a `dispatch_sync` on the same serial queue, so it waits behind
    /// the pending async write — the value is guaranteed on disk the instant the notification returns.
    func test_fix_lifecycleFlush_terminate_persistsToDisk() throws {
        let p = RSDefaultsPersistence.sharedInstance()!
        p.write("flushed", forKey: "rl_flush")
        NotificationCenter.default.post(name: NSNotification.Name("UIApplicationWillTerminateNotification"), object: nil)
        let url = try XCTUnwrap(RSUtils.getFileURL("rsDefaultsPersistence.plist"))
        let onDisk = NSDictionary(contentsOf: url)
        XCTAssertEqual(onDisk?["rl_flush"] as? String, "flushed")
    }

    /// THE FIX (lifecycle net, removal path). A pending async `removeObject` must also survive a
    /// background transition — assert the key is gone from the on-disk plist after the notification.
    func test_fix_lifecycleFlush_background_persistsRemovalToDisk() throws {
        let p = RSDefaultsPersistence.sharedInstance()!
        p.write("keep", forKey: "rl_rm")
        p.removeObject(forKey: "rl_rm")
        NotificationCenter.default.post(name: NSNotification.Name("UIApplicationDidEnterBackgroundNotification"), object: nil)
        let url = try XCTUnwrap(RSUtils.getFileURL("rsDefaultsPersistence.plist"))
        let onDisk = NSDictionary(contentsOf: url)
        XCTAssertNil(onDisk?["rl_rm"], "removal was not flushed to disk on background")
    }

    /// THE FIX (RSPreferenceManager). Removing the deprecated `NSUserDefaults synchronize` must not
    /// break persistence — the value is still readable and lands in standard defaults (the OS persists
    /// it automatically).
    func test_fix_preferenceManager_persistsWithoutSynchronize() {
        let pm = RSPreferenceManager.getInstance()
        pm.saveTraits("{\"name\":\"E2E\"}")
        XCTAssertEqual(pm.getTraits() as String, "{\"name\":\"E2E\"}")
        XCTAssertEqual(UserDefaults.standard.value(forKey: RSTraitsKey) as? String, "{\"name\":\"E2E\"}")
    }
}
