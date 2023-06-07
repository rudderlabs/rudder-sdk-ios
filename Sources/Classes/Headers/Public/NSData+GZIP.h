//
//  NSData+GZIP.h
//  Rudder
//
//  Created by Pallab Maiti on 17/05/23.
//

#import <Foundation/Foundation.h>


@interface NSData (GZIP)

- (nullable NSData *)gzippedDataWithCompressionLevel:(float)level;
- (nullable NSData *)gzippedData;
- (nullable NSData *)gunzippedData;
- (BOOL)isGzippedData;

@end
