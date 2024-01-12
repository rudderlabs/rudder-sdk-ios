//
//  Database.swift
//  Rudder
//
//  Created by Pallab Maiti on 11/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public let DB_OK = 0   /* Successful result */
/* beginning-of-error-codes */
public let DB_ERROR = 1   /* Generic error */
public let DB_INTERNAL = 2   /* Internal logic error in SQLite */
public let DB_PERM = 3   /* Access permission denied */
public let DB_ABORT = 4   /* Callback routine requested an abort */
public let DB_BUSY = 5   /* The database file is locked */
public let DB_LOCKED = 6   /* A table in the database is locked */
public let DB_NOMEM = 7   /* A malloc() failed */
public let DB_READONLY = 8   /* Attempt to write a readonly database */
public let DB_INTERRUPT = 9   /* Operation terminated by sqlite3_interrupt()*/
public let DB_IOERR = 10   /* Some kind of disk I/O error occurred */
public let DB_CORRUPT = 11   /* The database disk image is malformed */
public let DB_NOTFOUND = 12   /* Unknown opcode in sqlite3_file_control() */
public let DB_FULL = 13   /* Insertion failed because database is full */
public let DB_CANTOPEN = 14   /* Unable to open the database file */
public let DB_PROTOCOL = 15   /* Database lock protocol error */
public let DB_EMPTY = 16   /* Internal use only */
public let DB_SCHEMA = 17   /* The database schema changed */
public let DB_TOOBIG = 18   /* String or BLOB exceeds size limit */
public let DB_CONSTRAINT = 19   /* Abort due to constraint violation */
public let DB_MISMATCH = 20   /* Data type mismatch */
public let DB_MISUSE = 21   /* Library used incorrectly */
public let DB_NOLFS = 22   /* Uses OS features not supported on host */
public let DB_AUTH = 23   /* Authorization denied */
public let DB_FORMAT = 24   /* Not used */
public let DB_RANGE = 25   /* 2nd parameter to sqlite3_bind out of range */
public let DB_NOTADB = 26   /* File opened that is not a database file */
public let DB_NOTICE = 27   /* Notifications from sqlite3_log() */
public let DB_WARNING = 28   /* Warnings from sqlite3_log() */
public let DB_ROW = 100  /* sqlite3_step() has another row ready */
public let DB_DONE = 101  /* sqlite3_step() has finished executing */

public protocol Database {
    @discardableResult
    func open() -> Int32
    
    @discardableResult
    func prepare(_ zSql: UnsafePointer<CChar>!, _ nByte: Int32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32
    
    @discardableResult
    func step(_ pStmt: OpaquePointer!) -> Int32
    
    @discardableResult
    func finalize(_ pStmt: OpaquePointer!) -> Int32
    
    @discardableResult
    func bind_text(_ pStmt: OpaquePointer!, _ i: Int32, _ zData: UnsafePointer<CChar>!, _ nData: Int32, _ enc: (@convention(c) (UnsafeMutableRawPointer?) -> Void)!) -> Int32
    
    @discardableResult
    func bind_int(_ p: OpaquePointer!, _ i: Int32, _ iValue: Int32) -> Int32
    
    @discardableResult
    func errmsg() -> UnsafePointer<CChar>!
    
    @discardableResult
    func column_int(_: OpaquePointer!, _ iCol: Int32) -> Int32
    
    @discardableResult
    func column_text(_: OpaquePointer!, _ iCol: Int32) -> UnsafePointer<UInt8>!
}
