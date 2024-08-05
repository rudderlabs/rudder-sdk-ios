//
//  Utils.h
//  RSSDKCore
//
//  Created by Arnab Pal on 18/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RSMessage.h"
#import "RSDBMessage.h"
#import "RSServerConfigSource.h"

@class RSConfig;


NS_ASSUME_NONNULL_BEGIN


@interface RSUtils : NSObject

+ (NSString*) getTimestamp;
+ (NSString *)getFilePath:(NSString *)fileName;
+ (NSURL *)getFileURL:(NSString *) fileName;
+ (long) getTimeStampLong;
+ (NSString*) getUniqueId;
+ (NSString*) getLocale;
+ (NSString*) getDateString: (NSDate*) date;
+ (NSMutableArray<NSNumber *> *) sortArray:(NSMutableArray<NSNumber *>*) mutableArrayOfNumbers inOrder:(ORDER) order;
+ (unsigned int) getUTF8LengthForDict:(NSDictionary *)message;
+ (unsigned int) getUTF8Length: (NSString*) message;
+ (int) getNumberOfBatches:(RSDBMessage*) dbMessage withFlushQueueSize: (int) queueSize;
+ (NSMutableArray<NSString *>*) getBatch:(NSMutableArray<NSString *>*) messageDetails withQueueSize: (int) queueSize;
+(NSArray<NSString*>*) getArrayFromCSVString: (NSString *) csvString;
+ (NSString*) getCSVStringFromArray:(NSArray*) inputStrings;
+ (id) sanitizeObject: (id) val;
+ (NSString* _Nullable) serialize:(id) object;
+ (id _Nullable) deserialize:(NSString*) jsonString;
+ (BOOL) isValidURL:(NSURL*) url;
+ (NSString*) appendSlashToUrl:(NSString*) url;
+ (NSString* _Nullable) getBase64EncodedString:(NSString* __nonnull) inputString;
+ (BOOL) isApplicationUpdated;
+ (NSString* _Nullable) getDeviceId;
+ (BOOL)isFileExists:(NSString *)fileName;
+ (BOOL)doesFileExistsAtURL:(NSURL *)fileURL;
+ (BOOL)removeFile:(NSString *)fileName;
+ (BOOL) isDBMessageEmpty:(RSDBMessage*)dbMessage;
+ (BOOL) isEmptyString:(NSString *)value;
+ (BOOL) isValidIDFA:(NSString*)idfa;
+ (BOOL) isSpecialFloatingNumber:(NSNumber *)number;
+(NSArray*) extractParamFromURL: (NSURL*) deepLinkURL;
+ (NSString *)secondsToString:(int) delay;
extern unsigned int MAX_EVENT_SIZE;
extern unsigned int MAX_BATCH_SIZE;

@end

NS_ASSUME_NONNULL_END
