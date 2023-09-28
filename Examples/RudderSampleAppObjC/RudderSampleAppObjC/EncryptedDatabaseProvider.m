//
//  EncryptedDatabaseProvider.m
//  RudderDatabaseEncryption
//
//  Created by Pallab Maiti on 14/09/23.
//

#import "EncryptedDatabaseProvider.h"
#import "sqlite3.h"

@interface RSEncryptedDatabase : NSObject <RSDatabase>

@end

@implementation RSEncryptedDatabase {
    sqlite3 *db;
}

- (int)open_v2:(const char *)filename flags:(int)flags zVfs:(const char *)zVfs {
    return sqlite3_open_v2(filename, &db, flags, zVfs);
}


- (int)exec:(const char *)zSql xCallback:(callback)xCallback pArg:(void *)pArg pzErrMsg:(char * _Nullable *)pzErrMsg {
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
    return sqlite3_key(db, pKey, nKey);
}

- (int)last_insert_rowid {
    int64_t lastRowId = sqlite3_last_insert_rowid(db);
    return (int)lastRowId;
}

@end

@implementation EncryptedDatabaseProvider

- (id<RSDatabase>)getDatabase {
    return [RSEncryptedDatabase new];
}

@end
