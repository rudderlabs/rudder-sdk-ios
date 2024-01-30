//
//  RSDefaultsPersistence.m
//  Rudder
//
//  Created by Desu Sai Venkat on 30/01/24.
//

#import <Foundation/Foundation.h>
#import "RSUtils.h"
#import "RSLogger.h"
#import "RSDefaultsPersistence.h"

@implementation RSDefaultsPersistence

static RSDefaultsPersistence *instance;
static NSString * const userDefaultsCopied = @"userDefaultsCopied";

+ (instancetype)sharedInstance {
    if(instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[RSDefaultsPersistence alloc] init];
            [instance loadFromFile];
            [instance copyUserDefaultsToPersistenceIfNeeded];
        });
    }
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        data = [NSMutableDictionary dictionary];
        fileURL = [RSUtils getFileURL:@"rsDefaultsPersistence.plist"];
        dataAccessQueue = dispatch_queue_create("com.rudderstack.defaultspersistence", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)loadFromFile {
    if ([RSUtils doesFileExistsAtURL:fileURL]) {
        NSError *error = nil;
        NSDictionary* dictFromFile = [NSMutableDictionary dictionaryWithContentsOfURL:fileURL error:&error];
        if (error != nil && dictFromFile != nil) {
            [data addEntriesFromDictionary:dictFromFile];
        }
    }
}

// this should be invoked only once after the SDK has been updated from a version without DefaultsPersistence
// to a version with DefaultsPersistence to ensure that the persistence layer and user defaults are in same state.
- (void) copyUserDefaultsToPersistenceIfNeeded {
    BOOL userDefaultsCopiedAlready = [self readObjectForKey:userDefaultsCopied];
    if(!userDefaultsCopiedAlready) {
        NSArray* preferenceKeys = [RSPreferenceManager getPreferenceKeys];
        for(NSString* key in preferenceKeys) {
            id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if(value != nil) {
                [self writeObject:value forKey:key];
            }
        }
        // Set the flag to indicate that user defaults have been copied to the persistence layer
        [self writeObject:@YES forKey:userDefaultsCopied];
    }
}

// the caller of this method should ensure that this is dispatched to the dataAccessQueue synchronously
- (void)writeToFile {
    NSError* error = nil;
    [data writeToURL:fileURL error:&error];
    if (error != nil) {
        [RSLogger logError: [NSString stringWithFormat:@"Error writing to file: %@", error]];
    }
}

- (void) writeToFileSync {
    dispatch_sync(dataAccessQueue, ^{
        [self writeToFile];
    });
}

- (void)writeObject:(id)object forKey:(NSString *)key {
    dispatch_sync(dataAccessQueue, ^{
        if (object && key) {
            data[key] = object;
            [self writeToFile];
        }
    });
}

- (id)readObjectForKey:(NSString *)key {
    __block id result;
    dispatch_sync(dataAccessQueue, ^{
        result = data[key];
    });
    return result;
    
}

- (void)removeObjectForKey:(NSString *)key {
    dispatch_sync(dataAccessQueue, ^{
        [data removeObjectForKey:key];
        [self writeToFile];
    });
}

@end
