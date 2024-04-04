//
//  SQLiteDatabaseMock.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
@testable import Rudder

class SQLiteDatabaseMock: Database {
    var path: URL = .mockAny()
    
    var name: String = .mockAny()
    
    func open() -> Int32 {
        return 0
    }
    
    func prepare(_ zSql: UnsafePointer<CChar>!, _ nByte: Int32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32 {
        return 0
    }
    
    func step(_ pStmt: OpaquePointer!) -> Int32 {
        return 0
    }
    
    func finalize(_ pStmt: OpaquePointer!) -> Int32 {
        return 0
    }
    
    func bind_text(_ pStmt: OpaquePointer!, _ i: Int32, _ zData: UnsafePointer<CChar>!, _ nData: Int32, _ enc: (@convention(c) (UnsafeMutableRawPointer?) -> Void)!) -> Int32 {
        return 0
    }
    
    func bind_int(_ p: OpaquePointer!, _ i: Int32, _ iValue: Int32) -> Int32 {
        return 0
    }
    
    func errmsg() -> UnsafePointer<CChar>! {
        return NSString(string: "").utf8String
    }
    
    func column_int(_: OpaquePointer!, _ iCol: Int32) -> Int32 {
        return 0
    }
    
    func column_text(_: OpaquePointer!, _ iCol: Int32) -> UnsafePointer<UInt8>! {
        return "".toPointer()
    }
    
    func exec(_ sql: UnsafePointer<CChar>!, _ callback: (@convention(c) (UnsafeMutableRawPointer?, Int32, UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?, UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32)!, _ arg: UnsafeMutableRawPointer!, _ errmsg: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>!) -> Int32 {
        return 0
    }
    
    func close() -> Int32 {
        return 0
    }
}

extension String {
    func toPointer() -> UnsafePointer<UInt8>? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        let stream = OutputStream(toBuffer: buffer, capacity: data.count)
        stream.open()
        data.withUnsafeBytes{ dataBytes in
            let buffer: UnsafePointer<UInt8> = dataBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
            stream.write(buffer, maxLength: dataBytes.count)
        }
        stream.close()
        return UnsafePointer<UInt8>(buffer)
    }
}
