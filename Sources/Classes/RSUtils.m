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

+ (NSString *)getTimestamp {
    return [self getDateString:[[NSDate alloc] init]];
}

// returns number of seconds elapsed since 1970
+ (long) getTimeStampLong{
    NSDate *date = [[NSDate alloc] init];
    return [date timeIntervalSince1970];
}

+ (NSString *)getFilePath:(NSString *)fileName {
#if TARGET_OS_TV
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
#endif
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
    NSString* msgString = [self serialize:message];
    if(msgString == nil)
        return 0;
    return [self getUTF8Length:msgString];
}

+ (unsigned int) getUTF8Length:(NSString *)message {
    return (unsigned int)[[message dataUsingEncoding:NSUTF8StringEncoding] length];
}

+ (NSArray<NSNumber *> *) sortArray:(NSMutableArray<NSNumber *>*) arrayOfNumbers inOrder:(ORDER) order {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:order == ASCENDING];
    [arrayOfNumbers sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return [arrayOfNumbers copy];
}

+(NSArray<NSString*>*) getArrayFromCSVString: (NSString *) csvString {
    return [csvString componentsSeparatedByString:@","];
}

+(NSString*) getCSVStringFromArray:(NSArray*) inputStrings {
    return [inputStrings componentsJoinedByString:@","];
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

+ (NSString* _Nullable) serialize:(id) object {
    @try {
        id sanitizedObject = [self sanitizeObject:object];
        NSData *objectData = [NSJSONSerialization dataWithJSONObject:sanitizedObject options:0 error:nil];
        if (objectData != nil) {
            NSString *objectString = [[NSString alloc] initWithData:objectData encoding:NSUTF8StringEncoding];
            return objectString;
        }
    } @catch (NSException *exception) {
        [RSLogger logError:[[NSString alloc] initWithFormat:@"RSUtils: serialize: Failed to serialize the given object due to %@", exception]];
    }
    return nil;
}

+ (id _Nullable) deserialize:(NSString*) jsonString {
    @try {
        NSError *error = nil;
        NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if(error) {
            [RSLogger logError:[[NSString alloc] initWithFormat:@"RSUtils: deserialize: Failed to de-serialize the given string back to an object %@", jsonString]];
            return nil;
        }
        return object;
    } @catch (NSException *exception) {
        [RSLogger logError:[[NSString alloc] initWithFormat:@"RSUtils: deserialize: Failed to de-serialize the given string back to an object due to %@", exception]];
    }
    return nil;
}

// will stringify NSDate, NSURL Objects, invalid numbers (INFINITY, -INFINITY, NAN) to strings to ensure serialization doesn't fails
+ (id) sanitizeObject: (id) val {
    // return immediately if the object is valid
    if([NSJSONSerialization isValidJSONObject:val]) {
        return val;
    }
    
    // if the object is invalid, sanitize it
    if ([val isKindOfClass:[NSString class]] || [val isKindOfClass:[NSNull class]]) {
        return val;
    } else if ([val isKindOfClass:[NSNumber class]]) {
        // convert invalid numbers to strings
        if ([self isSpecialFloatingNumber:(NSNumber *) val]) {
            return [self serializeSpecialFloatingNumber:val];
        }
        return val;
    } else if ([val isKindOfClass:[NSDate class]]) {
        // handle date // isofy
        return [self getDateString:val];
    } else if ([val isKindOfClass:[NSURL class]]) {
        // handle url
        NSString* urlString = [val absoluteString];
        return urlString !=nil ? urlString: @"";
    } else if ([val isKindOfClass:[NSArray class]]) {
        // handle array
        return [self sanitizeArray:val];
    } else if ([val isKindOfClass:[NSDictionary class]] || [val isKindOfClass:[NSMutableDictionary class]]) {
        // handle dictionary
        return [self sanitizeDictionary:val];
    }
    [RSLogger logDebug:@"properties value is not serializable. using description"];
    return [val description];
}

+ (NSMutableDictionary *)sanitizeDictionary:(id)val {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *keys = [val allKeys];
    for (NSString *key in keys) {
        id value = [val objectForKey:key];
        if (![key isKindOfClass:[NSString class]]) {
            [RSLogger logDebug:@"key should be string. changing it to its description"];
        }
        [dict setValue:[self sanitizeObject:value] forKey:[key description]];
    }
    return dict;
}

+ (id)sanitizeArray:(id)val {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (id i in val) {
        [array addObject:[self sanitizeObject:i]];
    }
    return [array copy];
}

+ (BOOL) isSpecialFloatingNumber:(NSNumber *)number {
    return ([number isEqualToNumber:[NSDecimalNumber notANumber]]
            || isinf([number doubleValue]));
}

+ (NSString*) serializeSpecialFloatingNumber: (NSNumber *) number {
    if ([number isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return @"NaN";
    } else if ([number isEqualToNumber:[NSNumber numberWithDouble:INFINITY]]) {
        return @"Infinity";
    } else if ([number isEqualToNumber:[NSNumber numberWithDouble:-INFINITY]]) {
        return @"-Infinity";
    }
    return [number stringValue];
}

unsigned int MAX_EVENT_SIZE = 32 * 1024; // 32 KB
unsigned int MAX_BATCH_SIZE = 500 * 1024; // 500 KB

@end
