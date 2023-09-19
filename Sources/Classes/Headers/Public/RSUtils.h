//
//  Utils.h
//  RSSDKCore
//
//  Created by Arnab Pal on 18/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RSDBMessage.h"
#import "RSServerConfigSource.h"

@class RSConfig;


NS_ASSUME_NONNULL_BEGIN


@interface RSUtils : NSObject

+ (NSString*) getTimestamp;
+ (NSString *)getFilePath:(NSString *)fileName;
+ (long) getTimeStampLong;
+ (NSString*) getUniqueId;
+ (NSString*) getLocale;
+ (NSString*) getDateString: (NSDate*) date;
+ (NSMutableArray<NSNumber *> *) sortArray:(NSMutableArray<NSNumber *>*) mutableArrayOfNumbers inOrder:(ORDER) order;
+ (NSString*) getStringFromDict:(NSDictionary *) dict;
+ (unsigned int) getUTF8LengthForDict:(NSDictionary *)message;
+ (unsigned int) getUTF8Length: (NSString*) message;
+ (NSDictionary<NSString*, id>*) serializeDict: (NSDictionary<NSString*, id>* _Nullable) dict;
+ (NSArray*) serializeArray: (NSArray*) array;
+ (int) getNumberOfBatches:(RSDBMessage*) dbMessage withFlushQueueSize: (int) queueSize;
+ (NSMutableArray<NSString *>*) getBatch:(NSMutableArray<NSString *>*) messageDetails withQueueSize: (int) queueSize;
+(NSArray<NSString*>*) getArrayFromCSVString: (NSString *) csvString;
+ (NSString*) getCSVString:(NSArray*) inputStrings;
+ (NSString*) getJSONCSVString:(NSArray*) inputStrings;
+ (id _Nullable) deSerializeJSONString:(NSString*) jsonString;
+ (BOOL) isValidURL:(NSURL*) url;
+ (NSString*) appendSlashToUrl:(NSString*) url;
+ (NSString* _Nullable) getBase64EncodedString:(NSString* __nonnull) inputString;
+ (BOOL) isApplicationUpdated;
+ (NSString* _Nullable) getDeviceId;
+ (BOOL)isFileExists:(NSString *)fileName;
+ (BOOL)removeFile:(NSString *)fileName;
+ (BOOL) isDBMessageEmpty:(RSDBMessage*)dbMessage;
+ (BOOL) isEmptyString:(NSString *)value;

extern unsigned int MAX_EVENT_SIZE;
extern unsigned int MAX_BATCH_SIZE;

@end

NS_ASSUME_NONNULL_END
