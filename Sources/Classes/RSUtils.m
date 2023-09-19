//
//  Utils.m
//  RSSDKCore
//
//  Created by Arnab Pal on 18/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSUtils.h"
#import "RSContext.h"
#import "RSLogger.h"
#import "RSDBMessage.h"
#if TARGET_OS_WATCH
#import <WatchKit/WKInterfaceDevice.h>
#endif

@implementation RSUtils

+ (NSString*) getDateString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*) getStringFromDict:(NSDictionary *) dict {
    NSData *dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    if(dictData == nil)
        return @"";
    NSString *dictString = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
    return dictString;
}

+ (NSString *)getTimestamp {
    return [self getDateString:[[NSDate alloc] init]];
}

+ (NSString *)getFilePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    return [directory stringByAppendingPathComponent:fileName];
}

+ (BOOL)isFileExists:(NSString *)fileName {
    NSString *path = [self getFilePath:fileName];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)removeFile:(NSString *)fileName {
    NSString *path = [self getFilePath:fileName];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

// returns number of seconds elapsed since 1970
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

+ (unsigned int) getUTF8LengthForDict:(NSDictionary *)message {
    NSString* msgString = [self getStringFromDict:message];
    if(msgString == nil)
        return 0;
    return [self getUTF8Length:msgString];
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

+ (NSArray<NSNumber *> *) sortArray:(NSMutableArray<NSNumber *>*) arrayOfNumbers inOrder:(ORDER) order {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:order == ASCENDING];
    [arrayOfNumbers sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return [arrayOfNumbers copy];
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

+(NSArray<NSString*>*) getArrayFromCSVString: (NSString *) csvString {
    return [csvString componentsSeparatedByString:@","];
}

+(NSString*) getCSVString:(NSArray*) inputStrings {
    return [inputStrings componentsJoinedByString:@","];
}

+(NSString*) getJSONCSVString:(NSArray*) inputStrings {
    NSMutableString *JSONCSVString = [[NSMutableString alloc] init];
    for (int index = 0; index < inputStrings.count; index++) {
        [JSONCSVString appendFormat:@"\"%@\"", inputStrings[index]];
        if (index != inputStrings.count -1) {
            [JSONCSVString appendString:@","];
        }
    }
    return [JSONCSVString copy];
}


+ (int) getNumberOfBatches:(RSDBMessage*) dbMessage withFlushQueueSize: (int) queueSize {
    int messageCount = (int)dbMessage.messageIds.count;
    if (messageCount % queueSize == 0) {
        return messageCount / queueSize;
    } else {
        return (messageCount / queueSize) + 1;
    }
}

+ (NSArray*) getBatch:(NSArray*) messageDetails withQueueSize: (int) queueSize {
    if(messageDetails.count<=queueSize) {
        return messageDetails;
    }
    return [[NSMutableArray alloc] initWithArray:[messageDetails subarrayWithRange:NSMakeRange(0, queueSize)]];
}

+ (id _Nullable) deSerializeJSONString:(NSString*) jsonString {
    NSError *error = nil;
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error) {
        [RSLogger logError:[[NSString alloc] initWithFormat:@"Failed to serialize the given string back to object %@", jsonString]];
        return nil;
    }
    return object;
}

+ (BOOL) isValidURL:(NSURL*) url {
    return url && [url scheme] && [url host];
}

+ (NSString*) appendSlashToUrl:(NSString*) url {
    if([url hasSuffix:@"/"]){
        return url;
    }
    return [url stringByAppendingString:@"/"];
}

+ (NSString* _Nullable) getDeviceId {
    NSString * deviceId;
#if !TARGET_OS_WATCH
    deviceId = [[[[UIDevice currentDevice] identifierForVendor] UUIDString]lowercaseString];
#else
    deviceId = [[[[WKInterfaceDevice currentDevice] identifierForVendor]UUIDString] lowercaseString];
#endif
    return deviceId;
}

+ (NSString* _Nullable) getBase64EncodedString:(NSString* __nonnull) inputString {
    __block NSString* base64EncodedString = nil;
    if(inputString != nil && [inputString length] !=0) {
        NSData* inputStringData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_sync([RSContext getQueue], ^{
            base64EncodedString = [inputStringData base64EncodedStringWithOptions:0];
        });
    }
    return base64EncodedString;
}

+ (BOOL) isApplicationUpdated {
    NSString *previousVersion = [[RSPreferenceManager getInstance] getVersionNumber];
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    return (previousVersion && ![previousVersion isEqualToString:currentVersion]);
}

+ (BOOL) isDBMessageEmpty:(RSDBMessage*)dbMessage {
    return ([dbMessage.messages count] == 0 || [dbMessage.messageIds count] == 0);
}

+ (BOOL) isEmptyString:(NSString*)value {
    return (value == nil || value.length == 0);
}

unsigned int MAX_EVENT_SIZE = 32 * 1024; // 32 KB
unsigned int MAX_BATCH_SIZE = 500 * 1024; // 500 KB

@end
