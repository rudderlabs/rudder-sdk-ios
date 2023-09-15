//
//  RSDatabase.h
//  Rudder
//
//  Created by Pallab Maiti on 13/09/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef int (*callback)(void * _Nullable, int, char * _Nullable * _Nullable, char * _Nullable * _Nullable);

@protocol RSDatabase

- (int)open_v2:(const char * _Nullable)filename flags:(int)flags zVfs:(const char * _Nullable)zVfs;
- (int)exec:(const char * _Nullable)zSql xCallback:(callback _Nullable)xCallback pArg:(void * _Nullable)pArg pzErrMsg:(char * _Nullable * _Nullable)pzErrMsg;
- (int)prepare_v2:(const char * _Nullable)zSql nBytes:(int)nBytes ppStmt:(void * _Nullable * _Nullable)ppStmt pzTail:(const char * _Nullable * _Nullable)pzTail;

- (int)close;
- (int)step:(void * _Nullable)pStmt;
- (int)finalize:(void * _Nullable)pStmt;

- (int)column_int:(void * _Nullable)pStmt i:(int)i;
- (const unsigned char *)column_text:(void * _Nullable)pStmt i:(int)i;

- (int)key:(const void * _Nullable)pKey nKey:(int)nKey;

@end

NS_ASSUME_NONNULL_END
