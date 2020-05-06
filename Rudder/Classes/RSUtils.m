//
//  Utils.m
//  RSSDKCore
//
//  Created by Arnab Pal on 18/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSUtils.h"

@implementation Utils

+ (NSString*) getDateString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [[NSTimeZone alloc] initWithName:@"UTC"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)getTimestamp {
    return [Utils getDateString:[[NSDate alloc] init]];
}

+ (const char *)getDBPath {
    NSURL *urlDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask][0];
    NSURL *fileUrl = [urlDirectory URLByAppendingPathComponent:@"rl_persistence.sqlite"];
    return [[fileUrl path] UTF8String];
}

+ (long) getTimeStampLong{
    NSDate *date = [[NSDate alloc] init];
    return [date timeIntervalSince1970];
}

+ (NSString *) getUniqueId {
    NSUUID *uuid = [NSUUID UUID];
    return [[uuid UUIDString] lowercaseString];
}

+ (NSString*) getLocale {
    NSLocale *locale = [NSLocale currentLocale];
    if (@available(iOS 10.0, *)) {
        return [[NSString alloc] initWithFormat:@"%@-%@", [locale languageCode], [locale countryCode]];
    } else {
        // Fallback on earlier versions
        return @"NA";
    }
}

+ (unsigned int) getUTF8Length:(NSString *)message {
    return (unsigned int)[[message dataUsingEncoding:NSUTF8StringEncoding] length];
}

unsigned int MAX_EVENT_SIZE = 32 * 1024; // 32 KB
unsigned int MAX_BATCH_SIZE = 500 * 1024; // 500 KB

@end
