//
//  RSContext.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSContext.h"
#import "RSUtils.h"
#import "RSLogger.h"

@implementation RSContext

int const RSATTNotDetermined = 0;
int const RSATTRestricted = 1;
int const RSATTDenied = 2;
int const RSATTAuthorize = 3;


static dispatch_queue_t queue;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        if (queue == nil) {
            queue = dispatch_queue_create("com.rudder.RSContext", NULL);
        }
        
        self->preferenceManager = [RSPreferenceManager getInstance];
        
        _app = [[RSApp alloc] init];
        _device = [[RSDeviceInfo alloc] init];
        _library = [[RSLibraryInfo alloc] init];
        _os = [[RSOSInfo alloc] init];
        _screen = [[RSScreenInfo alloc] init];

        _locale = [RSUtils getLocale];
        _network = [[RSNetwork alloc] init];
        _timezone = [[NSTimeZone localTimeZone] name];
        _externalIds = nil;
        
        dispatch_sync(queue, ^{
            NSString *traitsJson = [preferenceManager getTraits];
            if (traitsJson == nil) {
                // no persisted traits, create new and persist
                [self createAndPersistTraits];
            } else {
                NSError *error;
                NSDictionary *traitsDict = [NSJSONSerialization JSONObjectWithData:[traitsJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                if (error == nil) {
                    _traits = [traitsDict mutableCopy];
                } else {
                    // persisted traits persing error. initiate blank
                    [self createAndPersistTraits];
                }
            }
        
            // get saved external Ids from prefs
            NSString *externalIdJson = [preferenceManager getExternalIds];
            if (externalIdJson != nil) {
                NSError *error;
                NSDictionary *externalIdDict = [NSJSONSerialization JSONObjectWithData:[externalIdJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                if (error == nil) {
                    _externalIds = [externalIdDict mutableCopy];
                }
            }
        });
    }
    return self;
}

+ (dispatch_queue_t) getQueue {
    return queue;
}

- (void) createAndPersistTraits {
    RSTraits* traits = [[RSTraits alloc] init];
    traits.anonymousId = [preferenceManager getAnonymousId];
    _traits = [[traits dict]  mutableCopy];
    
    [self persistTraits];
}

- (void) resetTraits {
    dispatch_async(queue, ^{
        RSTraits* traits = [[RSTraits alloc] init];
        traits.anonymousId = [preferenceManager getAnonymousId];
        [_traits removeAllObjects];
        [_traits setValuesForKeysWithDictionary:[traits dict]];
    });
}

- (void)updateTraits:(RSTraits *)traits {
    dispatch_async(queue, ^{
        NSString* existingId = (NSString*)[_traits objectForKey:@"userId"];
        NSString* userId = (NSString*) traits.userId;
        
        if(existingId!=nil && userId!=nil && ![existingId isEqual:userId])
        {
            _traits = [[traits dict]mutableCopy];
            [self resetExternalIds];
            return;
        }
        [_traits setValuesForKeysWithDictionary:[traits dict]];
    });
} 

-(void) persistTraits {
    dispatch_async(queue, ^{
        NSData *traitsJsonData = [NSJSONSerialization dataWithJSONObject:[RSUtils serializeDict:_traits] options:0 error:nil];
        NSString *traitsString = [[NSString alloc] initWithData:traitsJsonData encoding:NSUTF8StringEncoding];
        
        [preferenceManager saveTraits:traitsString];
    });
}

- (void)updateTraitsDict:(NSMutableDictionary<NSString *, NSObject *> *)traitsDict {
    dispatch_async(queue, ^{
        _traits = traitsDict;
    });
}

- (void)updateTraitsAnonymousId {
    dispatch_async(queue, ^{
        _traits[@"anonymousId"] = [preferenceManager getAnonymousId];
    });
}

- (void)putDeviceToken:(NSString *)deviceToken {
    dispatch_async(queue, ^{
        _device.token = deviceToken;
    });
}

- (void)putAdvertisementId:(NSString *_Nonnull)idfa {
    // This isn't ideal.  We're doing this because we can't actually check if IDFA is enabled on
    // the customer device.  Apple docs and tests show that if it is disabled, one gets back all 0's.
    dispatch_async(queue, ^{
        if( idfa != nil && [idfa length] != 0) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"IDFA: %@", idfa]];
            BOOL adTrackingEnabled = (![idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"]);
            _device.adTrackingEnabled = adTrackingEnabled;
            
            if (adTrackingEnabled) {
                _device.advertisingId = idfa;
            }
        }
    });
}

- (void)updateExternalIds:(NSMutableArray *)externalIds {
    dispatch_async(queue, ^{
        if(_externalIds == nil)
        {
            _externalIds = [[NSMutableArray alloc] init];
        }
        
        NSMutableArray *newExternalIds = [externalIds mutableCopy];
        if (_externalIds.count > 0) {
            NSMutableArray *repeatingExternalIds = [[NSMutableArray alloc] init];
            for (NSMutableDictionary *newExternalId in newExternalIds) {
                for (NSMutableDictionary *externalId in _externalIds) {
                    if ([externalId[@"type"] isEqualToString:newExternalId[@"type"]]){
                        externalId[@"id"] = newExternalId[@"id"];
                        [repeatingExternalIds addObject:newExternalId];
                        break;
                    }
                }
            }
            [newExternalIds removeObjectsInArray:repeatingExternalIds];
        }

        if ([newExternalIds count]) {
            [_externalIds addObjectsFromArray: newExternalIds];
        }
    });
}

- (void)persistExternalIds {
    dispatch_async(queue, ^{
        if (_externalIds != nil) {
            // update persistence storage
            NSData *externalIdJsonData = [NSJSONSerialization dataWithJSONObject:[RSUtils serializeArray:[_externalIds copy]] options:0 error:nil];
            NSString *externalIdJson = [[NSString alloc] initWithData:externalIdJsonData encoding:NSUTF8StringEncoding];
            [preferenceManager saveExternalIds:externalIdJson];
        }
    });
}

- (void)resetExternalIds {
    dispatch_async(queue, ^{
        _externalIds = nil;
        [preferenceManager clearExternalIds];
    });
}

- (void)putAppTrackingConsent:(int)att {
    dispatch_async(queue, ^{
        if (att < RSATTNotDetermined) {
            _device.attTrackingStatus = RSATTNotDetermined;
        } else if (att > RSATTAuthorize) {
            _device.attTrackingStatus = RSATTAuthorize;
        } else {
            _device.attTrackingStatus = att;
        }
    });
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    dispatch_sync(queue, ^{
        [tempDict setObject:[_app dict] forKey:@"app"];
        [tempDict setObject:[RSUtils serializeDict:_traits] forKey:@"traits"];
        [tempDict setObject:[_library dict] forKey:@"library"];
        [tempDict setObject:[_os dict] forKey:@"os"];
        [tempDict setObject:[_screen dict] forKey:@"screen"];
        if (_userAgent) {
            [tempDict setObject:_userAgent forKey:@"userAgent"];
        }
        
        [tempDict setObject:_locale forKey:@"locale"];
        [tempDict setObject:[_device dict] forKey:@"device"];
        [tempDict setObject:[_network dict] forKey:@"network"];
        [tempDict setObject:_timezone forKey:@"timezone"];
        if (_externalIds != nil) {
            [tempDict setObject:_externalIds forKey:@"externalId"];
        }
    });
    return [tempDict copy];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    RSContext *copy = [[[self class] allocWithZone:zone] init];
    
    copy.app = self.app;
    
    copy.library = self.library;
    copy.os = self.os;
    copy.screen = self.screen;
    copy.userAgent = self.userAgent;
    copy.locale = self.locale;
    copy.device = self.device;
    copy.network = self.network;
    copy.timezone = self.timezone;
    dispatch_sync(queue, ^{
        copy.traits = [self.traits copy];
        copy.externalIds = [self.externalIds copy];
    });
    
    return copy;
}

@end
