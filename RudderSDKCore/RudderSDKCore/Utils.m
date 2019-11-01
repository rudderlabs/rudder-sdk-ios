//
//  Utils.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 18/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "Utils.h"

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

+ (char *)getDBPath {
    NSURL *urlDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask][0];
//    NSURL *urlDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
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
    return [[NSString alloc] initWithFormat:@"%@-%@", [locale languageCode], [locale countryCode]];
}

@end
