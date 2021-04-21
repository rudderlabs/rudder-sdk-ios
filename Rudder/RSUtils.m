//
//  Utils.m
//  RSSDKCore
//
//  Created by Arnab Pal on 18/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSUtils.h"
#import "RSLogger.h"

@implementation RSUtils

+ (NSString*) getDateString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [[NSTimeZone alloc] initWithName:@"UTC"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)getTimestamp {
    return [RSUtils getDateString:[[NSDate alloc] init]];
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

+ (id) serializeValue: (id) val {
    if ([val isKindOfClass:[NSString class]] ||
        [val isKindOfClass:[NSNumber class]] ||
        [val isKindOfClass:[NSNull class]]
        ) {
        return val;
    } else if ([val isKindOfClass:[NSArray class]]) {
        // handle array
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (id i in val) {
            [array addObject:[self serializeValue:i]];
        }
        return [array copy];
    } else if ([val isKindOfClass:[NSDictionary class]] ||
               [val isKindOfClass:[NSMutableDictionary class]] 
               ) {
        // handle dictionary
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSArray *keys = [val allKeys];
        for (NSString *key in keys) {
            id value = [val objectForKey:key];
            if (![key isKindOfClass:[NSString class]]) {
                [RSLogger logDebug:@"key should be string. changing it to its description"];
            }
            [dict setValue:[self serializeValue:value] forKey:[key description]];
        }
        return [dict copy];
    } else if ([val isKindOfClass:[NSDate class]]) {
        // handle date // isofy
        return [self getDateString:val];
    } else if ([val isKindOfClass:[NSURL class]]) {
        // handle url
        return [val absoluteString];
    }
    [RSLogger logDebug:@"properties value is not serializable. using description"];
    return [val description];
}

+ (NSDictionary<NSString *,id> *)serializeDict:(NSDictionary<NSString*, id>*)dict {
    // if dict is not null
    if (dict) {
        NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] initWithCapacity:dict.count];
        NSArray *keys = [dict allKeys];
        for (NSString* key in keys) {
            id val = [self serializeValue: [dict objectForKey:key]];
            [returnDict setValue:val forKey:key];
        }
        
        return [returnDict copy];
    }
    return dict;
}

+ (NSArray*) serializeArray:(NSArray*) array {
    if (array) {
        NSMutableArray *returnArray = [[NSMutableArray alloc] init];
        for (id i in array) {
            [returnArray addObject:[self serializeValue:i]];
        }
        return [returnArray copy];
    }
    return array;
}

unsigned int MAX_EVENT_SIZE = 32 * 1024; // 32 KB
unsigned int MAX_BATCH_SIZE = 500 * 1024; // 500 KB

@end
