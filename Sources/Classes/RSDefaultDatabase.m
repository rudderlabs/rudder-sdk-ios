//
//  RSDefaultDatabase.m
//  Rudder
//
//  Created by Pallab Maiti on 13/09/23.
//

#import "RSDefaultDatabase.h"
#import <sqlite3.h>

@implementation RSDefaultDatabase {
    sqlite3 *db;
}

- (int)open_v2:(const char *)filename flags:(int)flags zVfs:(const char *)zVfs {
    return sqlite3_open_v2(filename, &db, flags, zVfs);
}

- (int)exec:(const char *)zSql xCallback:(callback)xCallback pArg:(void *)pArg pzErrMsg:(char **)pzErrMsg {
    return sqlite3_exec(db, zSql, xCallback, pArg, pzErrMsg);
}

- (int)close {
    return sqlite3_close(db);
}

- (int)step:(void *)pStmt {
    return sqlite3_step(pStmt);
}

- (int)finalize:(void *)pStmt {
    return sqlite3_finalize(pStmt);
}

- (int)prepare_v2:(const char *)zSql nBytes:(int)nBytes ppStmt:(void **)ppStmt pzTail:(const char **)pzTail {
    return sqlite3_prepare_v2(db, zSql, nBytes, (sqlite3_stmt **)(ppStmt), pzTail);
}

- (int)column_int:(void *)pStmt i:(int)i {
    return sqlite3_column_int(pStmt, i);
}

- (const unsigned char *)column_text:(void *)pStmt i:(int)i {
    return sqlite3_column_text(pStmt, i);
}

- (int)key:(const void *)pKey nKey:(int)nKey {
    return -1;
}

@end
