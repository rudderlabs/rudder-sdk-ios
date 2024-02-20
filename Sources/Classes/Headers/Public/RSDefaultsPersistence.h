//
//  RSDefaultsPersistence.h
//  Rudder
//
//  Created by Desu Sai Venkat on 30/01/24.
//

@interface RSDefaultsPersistence : NSObject {
    NSMutableDictionary *data;
    NSURL *fileURL;
    dispatch_queue_t dataAccessQueue;
}

- (instancetype)init NS_UNAVAILABLE NS_SWIFT_UNAVAILABLE("Use `RSDefaultsPersistence.sharedInstance()` instead.");
+ (instancetype)sharedInstance;
- (void) copyStandardDefaultsToPersistenceIfNeeded;
- (void) clearState;
- (void)writeObject:(id)object forKey:(NSString *)key;
- (id)readObjectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

@end
