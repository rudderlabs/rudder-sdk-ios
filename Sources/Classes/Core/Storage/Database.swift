//
//  Database.swift
//  Rudder
//
//  Created by Pallab Maiti on 11/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@objc(RSDatabaseError)
public class DatabaseError: NSObject {
    public static let OK = 0   /* Successful result */
    /* beginning-of-error-codes */
    public static let ERROR = 1   /* Generic error */
    public static let INTERNAL = 2   /* Internal logic error in SQLite */
    public static let PERM = 3   /* Access permission denied */
    public static let ABORT = 4   /* Callback routine requested an abort */
    public static let BUSY = 5   /* The database file is locked */
    public static let LOCKED = 6   /* A table in the database is locked */
    public static let NOMEM = 7   /* A malloc() failed */
    public static let READONLY = 8   /* Attempt to write a readonly database */
    public static let INTERRUPT = 9   /* Operation terminated by sqlite3_interrupt()*/
    public static let IOERR = 10   /* Some kind of disk I/O error occurred */
    public static let CORRUPT = 11   /* The database disk image is malformed */
    public static let NOTFOUND = 12   /* Unknown opcode in sqlite3_file_control() */
    public static let FULL = 13   /* Insertion failed because database is full */
    public static let CANTOPEN = 14   /* Unable to open the database file */
    public static let PROTOCOL = 15   /* Database lock protocol error */
    public static let EMPTY = 16   /* Internal use only */
    public static let SCHEMA = 17   /* The database schema changed */
    public static let TOOBIG = 18   /* String or BLOB exceeds size limit */
    public static let CONSTRAINT = 19   /* Abort due to constraint violation */
    public static let MISMATCH = 20   /* Data type mismatch */
    public static let MISUSE = 21   /* Library used incorrectly */
    public static let NOLFS = 22   /* Uses OS features not supported on host */
    public static let AUTH = 23   /* Authorization denied */
    public static let FORMAT = 24   /* Not used */
    public static let RANGE = 25   /* 2nd parameter to sqlite3_bind out of range */
    public static let NOTADB = 26   /* File opened that is not a database file */
    public static let NOTICE = 27   /* Notifications from sqlite3_log() */
    public static let WARNING = 28   /* Warnings from sqlite3_log() */
    public static let ROW = 100  /* sqlite3_step() has another row ready */
    public static let DONE = 101  /* sqlite3_step() has finished executing */
}

public protocol Database {
    var path: URL { get set }
    var name: String { get set }
    
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
