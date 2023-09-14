//
//  RSDatabase.h
//  Rudder
//
//  Created by Pallab Maiti on 13/09/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RSDatabase

- (int)sqlite3_open_v2:(const char *)filename flags:(int)flags zVfs:(const char * __nullable)zVfs;
- (int)sqlite3_exec:(const char *)zSql xCallback:(void * __nullable)xCallback pArg:(void * __nullable)pArg pzErrMsg:(char ** __nullable)pzErrMsg;
- (int)sqlite3_prepare_v2:(const char *)zSql nBytes:(int)nBytes ppStmt:(void **)ppStmt pzTail:(const char **)pzTail;

- (int)sqlite3_close;
- (int)sqlite3_step:(void *)pStmt;
- (int)sqlite3_finalize:(void *)pStmt;

- (int)sqlite3_column_int:(void *)pStmt i:(int)i;
- (const unsigned char *)sqlite3_column_text:(void *)pStmt i:(int)i;

- (int)sqlite3_key:(const void *)pKey nKey:(int)nKey;

@end

NS_ASSUME_NONNULL_END
