//
//  Utils.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 18/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (NSString*) getTimestamp;
+ (char *) getDBPath;
+ (long) getTimeStampLong;
+ (NSString*) getUniqueId;
+ (NSString*) getLocale;
+ (NSString*) getDateString: (NSDate*) date;

@end

NS_ASSUME_NONNULL_END
