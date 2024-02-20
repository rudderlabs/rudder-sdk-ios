//
//  DefaultDatabase.swift
//  Rudder
//
//  Created by Pallab Maiti on 11/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import SQLite3

class DefaultDatabase: Database {
    var path: URL
    var name: String
    private var database: OpaquePointer?
    
    init(path: URL, name: String) {
        self.path = path
        self.name = name
    }
    
    func open() -> Int32 {
        return sqlite3_open_v2(path.appendingPathComponent(name).path, &database, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil)
    }
    
    func prepare(_ zSql: UnsafePointer<CChar>!, _ nByte: Int32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32 {
        return sqlite3_prepare_v2(database, zSql, nByte, ppStmt, pzTail)
    }
    
    func step(_ pStmt: OpaquePointer!) -> Int32 {
        return sqlite3_step(pStmt)
    }
    
    func finalize(_ pStmt: OpaquePointer!) -> Int32 {
        return sqlite3_finalize(pStmt)
    }
    
    func bind_text(_ pStmt: OpaquePointer!, _ i: Int32, _ zData: UnsafePointer<CChar>!, _ nData: Int32, _ enc: (@convention(c) (UnsafeMutableRawPointer?) -> Void)!) -> Int32 {
        return sqlite3_bind_text(pStmt, i, zData, nData, enc)
    }
    
    func bind_int(_ p: OpaquePointer!, _ i: Int32, _ iValue: Int32) -> Int32 {
        return sqlite3_bind_int(p, i, iValue)
    }
    
    func errmsg() -> UnsafePointer<CChar>! {
        sqlite3_errmsg(database)
    }
    
    func column_int(_ pStmt: OpaquePointer!, _ iCol: Int32) -> Int32 {
        return sqlite3_column_int(pStmt, iCol)
    }
    
    func column_text(_ pStmt: OpaquePointer!, _ iCol: Int32) -> UnsafePointer<UInt8>! {
        return sqlite3_column_text(pStmt, iCol)
    }
}
