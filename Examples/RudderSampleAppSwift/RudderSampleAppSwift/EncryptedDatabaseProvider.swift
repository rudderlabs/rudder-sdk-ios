//
//  EncryptedDatabaseProvider.swift
//  RudderSampleAppSwift
//
//  Created by Pallab Maiti on 14/09/23.
//  Copyright © 2023 RudderStack. All rights reserved.
//

import Foundation
import Rudder

class EncryptedDatabase: RSDatabase {
    
    private var db: OpaquePointer?
    
    func open_v2(_ filename: UnsafePointer<CChar>?, flags: Int32, zVfs: UnsafePointer<CChar>?) -> Int32 {
        return sqlite3_open_v2(filename, &db, flags, zVfs)
    }
    
    func exec(_ zSql: UnsafePointer<CChar>?, xCallback: callback?, pArg: UnsafeMutableRawPointer?, pzErrMsg: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32 {
        return sqlite3_exec(db, zSql, xCallback, pArg, pzErrMsg)
    }
        
    func prepare_v2(_ zSql: UnsafePointer<CChar>, nBytes: Int32, ppStmt: UnsafeMutablePointer<UnsafeMutableRawPointer?>?, pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>?) -> Int32 {
        return sqlite3_prepare_v2(db, zSql, nBytes, UnsafeMutablePointer(OpaquePointer(ppStmt)), pzTail)
    }
    
    func close() -> Int32 {
        return sqlite3_close(db)
    }
    
    func step(_ pStmt: UnsafeMutableRawPointer?) -> Int32 {
        return sqlite3_step(OpaquePointer(pStmt))
    }
    
    func finalize(_ pStmt: UnsafeMutableRawPointer?) -> Int32 {
        return sqlite3_finalize(OpaquePointer(pStmt))
    }
    
    func column_int(_ pStmt: UnsafeMutableRawPointer?, i: Int32) -> Int32 {
        return sqlite3_column_int(OpaquePointer(pStmt), i)
    }
    
    func column_text(_ pStmt: UnsafeMutableRawPointer?, i: Int32) -> UnsafePointer<UInt8> {
        return sqlite3_column_text(OpaquePointer(pStmt), i)
    }
    
    func key(_ pKey: UnsafeRawPointer?, nKey: Int32) -> Int32 {
        return sqlite3_key(db, pKey, nKey)
    }
}

class EncryptedDatabaseProvider: RSDatabaseProvider {
    func getDatabase() -> RSDatabase {
        return EncryptedDatabase()
    }
}
