//
//  Utils.h
//  RSSDKCore
//
//  Created by Arnab Pal on 18/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSDBMessage.h"
#import "RSServerConfigSource.h"
#import "RSConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSUtils : NSObject

+ (NSString*) getTimestamp;
+ (const char *) getDBPath;
+ (long) getTimeStampLong;
+ (NSString*) getUniqueId;
+ (NSString*) getLocale;
+ (NSString*) getDateString: (NSDate*) date;
+ (unsigned int) getUTF8Length: (NSString*) message;
+ (NSDictionary<NSString*, id>*) serializeDict: (NSDictionary<NSString*, id>* _Nullable) dict;
+ (NSArray*) serializeArray: (NSArray*) array;
+ (int) getNumberOfBatches:(RSDBMessage*) dbMessage withFlushQueueSize: (int) queueSize;
+ (NSMutableArray<NSString *>*) getBatch:(NSMutableArray<NSString *>*) messageDetails withQueueSize: (int) queueSize;
+ (BOOL) isValidURL:(NSURL*) url;
+ (NSString*) appendSlashToUrl:(NSString*) url;
+ (NSString * __nullable) getDataPlaneUrlFrom:(RSServerConfigSource *) serverConfig andRSConfig:(RSConfig *) rsConfig;

extern unsigned int MAX_EVENT_SIZE;
extern unsigned int MAX_BATCH_SIZE;

@end

NS_ASSUME_NONNULL_END
