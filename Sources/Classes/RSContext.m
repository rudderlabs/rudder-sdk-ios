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
#import "RSClient.h"
#import "RSConstants.h"

@implementation RSContext

static dispatch_queue_t queue;

- (instancetype)initWithConfig:(RSConfig *) config {
    self = [super init];
    if (self) {
        
        if (queue == nil) {
            queue = dispatch_queue_create("com.rudder.RSContext", NULL);
        }
        
        self->preferenceManager = [RSPreferenceManager getInstance];
        
        NSString* _anonymousId = [self->preferenceManager getAnonymousId];
        if(_anonymousId == nil) {
            _anonymousId = [RSUtils getUniqueId];
        }
        [self->preferenceManager saveAnonymousId:_anonymousId];
        
        _app = [[RSApp alloc] init];
        _device = [[RSDeviceInfo alloc] initWithConfig:config];
        _library = [[RSLibraryInfo alloc] init];
        _os = [[RSOSInfo alloc] init];
        _screen = [[RSScreenInfo alloc] init];
        
        _locale = [RSUtils getLocale];
        _network = [[RSNetwork alloc] init];
        _timezone = [[NSTimeZone localTimeZone] name];
        _externalIds = nil;
        
        
        NSString *traitsJson = [preferenceManager getTraits];
        if (traitsJson == nil) {
            // no persisted traits, create new and persist
            [self createAndPersistTraits];
        } else {
            NSError *error;
            NSDictionary *traitsDict = [NSJSONSerialization JSONObjectWithData:[traitsJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
            if (error == nil) {
                _traits = [traitsDict mutableCopy];
                _traits[@"anonymousId"] = _anonymousId;
                [self persistTraits];
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
        
    }
    return self;
}

- (instancetype) initWithDict:(NSDictionary*) dict {
    self = [super init];
    if(self) {
        _app = [[RSApp alloc] initWithDict:dict[@"app"]];
        _traits = dict[@"traits"];
        _library = [[RSLibraryInfo alloc] initWithDict:dict[@"library"]];
        _os = [[RSOSInfo alloc] initWithDict:dict[@"os"]];
        _screen = [[RSScreenInfo alloc] initWithDict:dict[@"screen"]]; 
        _userAgent = dict[@"userAgent"];
        _locale = dict[@"locale"];
        _device = [[RSDeviceInfo alloc] initWithDict:dict[@"device"]];
        _network = [[RSNetwork alloc] initWithDict:dict[@"network"]]; 
        _timezone = dict[@"timezone"];
        _sessionId = dict[@"sessionId"];
        if(dict[@"sessionStart"]) {
            _sessionStart = dict[@"sessionStart"];
        }
        _externalIds = dict[@"externalIds"];
        
    }
    return self;
}

+ (dispatch_queue_t) getQueue {
    if (queue == nil) {
        queue = dispatch_queue_create("com.rudder.RSContext", NULL);
    }
    return queue;
}

- (void) createAndPersistTraits {
    RSTraits* traits = [[RSTraits alloc] init];
    traits.anonymousId = [preferenceManager getAnonymousId];
    _traits = [[traits dict]  mutableCopy];
    
    [self persistTraits];
}

- (void) resetTraits {
    dispatch_sync(queue, ^{
        RSTraits* traits = [[RSTraits alloc] init];
        traits.anonymousId = [self->preferenceManager getAnonymousId];
        [self->_traits removeAllObjects];
        [self->_traits setValuesForKeysWithDictionary:[traits dict]];
    });
}

- (void) updateTraits:(RSTraits *)traits {
    dispatch_sync(queue, ^{
        NSString* existingId = (NSString*)[self->_traits objectForKey:@"userId"];
        NSString* userId = (NSString*) traits.userId;
        
        if(existingId!=nil && userId!=nil && ![existingId isEqual:userId])
        {
            self->_traits = [[traits dict] mutableCopy];
            [self resetExternalIds];
            return;
        }
        [self->_traits setValuesForKeysWithDictionary:[traits dict]];
    });
}

- (void) persistTraitsOnQueue {
    dispatch_sync(queue, ^{
        [self persistTraits];
    });
}

-(void) persistTraits {
    NSData *traitsJsonData = [NSJSONSerialization dataWithJSONObject:[RSUtils serializeDict:self->_traits] options:0 error:nil];
    NSString *traitsString = [[NSString alloc] initWithData:traitsJsonData encoding:NSUTF8StringEncoding];
    [self->preferenceManager saveTraits:traitsString];
}

- (void)updateTraitsDict:(NSMutableDictionary<NSString *, NSObject *> *)traitsDict {
    dispatch_sync(queue, ^{
        self->_traits = traitsDict;
    });
}

- (void)updateTraitsAnonymousId {
    dispatch_sync(queue, ^{
        self->_traits[@"anonymousId"] = [self->preferenceManager getAnonymousId];
    });
}

- (void)putDeviceToken:(NSString *)deviceToken {
    dispatch_sync(queue, ^{
        self->_device.token = deviceToken;
    });
}

- (void)putAdvertisementId:(NSString *_Nonnull)idfa {
    // This isn't ideal.  We're doing this because we can't actually check if IDFA is enabled on
    // the customer device.  Apple docs and tests show that if it is disabled, one gets back all 0's.
    dispatch_sync(queue, ^{
        if( idfa != nil && [idfa length] != 0) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"IDFA: %@", idfa]];
            BOOL adTrackingEnabled = (![idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"]);
            self->_device.adTrackingEnabled = adTrackingEnabled;
            
            if (adTrackingEnabled) {
                self->_device.advertisingId = idfa;
            }
        }
    });
}

- (void)updateExternalIds:(NSMutableArray *)externalIds {
    dispatch_sync(queue, ^{
        if(self->_externalIds == nil)
        {
            self->_externalIds = [[NSMutableArray alloc] init];
        }
        
        NSMutableArray *newExternalIds = [externalIds mutableCopy];
        if (self->_externalIds.count > 0) {
            NSMutableArray *repeatingExternalIds = [[NSMutableArray alloc] init];
            for (NSMutableDictionary *newExternalId in newExternalIds) {
                for (NSMutableDictionary *externalId in self->_externalIds) {
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
            [self->_externalIds addObjectsFromArray: newExternalIds];
        }
    });
}

- (void)persistExternalIds {
    dispatch_sync(queue, ^{
        if (self->_externalIds != nil) {
            // update persistence storage
            NSData *externalIdJsonData = [NSJSONSerialization dataWithJSONObject:[RSUtils serializeArray:[self->_externalIds copy]] options:0 error:nil];
            NSString *externalIdJson = [[NSString alloc] initWithData:externalIdJsonData encoding:NSUTF8StringEncoding];
            [self->preferenceManager saveExternalIds:externalIdJson];
        }
    });
}

- (NSArray<NSDictionary<NSString*, NSObject*>*>* __nullable) getExternalIds {
    __block NSArray<NSDictionary<NSString*, NSObject*>*>* externalIdsCopy = nil;
    dispatch_sync(queue, ^{
        externalIdsCopy = [self->_externalIds copy];
    });
    return externalIdsCopy;
}

- (void) resetExternalIdsOnQueue {
    dispatch_sync(queue, ^{
        [self resetExternalIds];
    });
}

- (void)resetExternalIds {
    self->_externalIds = nil;
    [self->preferenceManager clearExternalIds];
}

- (void)putAppTrackingConsent:(int)att {
    dispatch_sync(queue, ^{
        if (att < RSATTNotDetermined) {
            self->_device.attTrackingStatus = RSATTNotDetermined;
        } else if (att > RSATTAuthorize) {
            self->_device.attTrackingStatus = RSATTAuthorize;
        } else {
            self->_device.attTrackingStatus = att;
        }
    });
}

- (void) setSessionData:(RSUserSession *) userSession {
    dispatch_sync(queue, ^{
        if ([userSession getSessionId] != nil) {
            self->_sessionId = [userSession getSessionId];
            if([userSession getSessionStart]) {
                self->_sessionStart = YES;
                [userSession setSessionStart:NO];
            }
        }
    });
}

- (void)setConsentData:(NSArray <NSString *> *)deniedConsentIds {
    dispatch_sync(queue, ^{
        self->consentManagement = @{@"deniedConsentIds": deniedConsentIds};
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
        if([_network dict].count > 0) {
            [tempDict setObject:[_network dict] forKey:@"network"];
        }
        [tempDict setObject:_timezone forKey:@"timezone"];
        if (_externalIds != nil) {
            [tempDict setObject:_externalIds forKey:@"externalId"];
        }
        if (_sessionId != nil) {
            [tempDict setObject:_sessionId forKey:@"sessionId"];
            if(_sessionStart) {
                [tempDict setObject:@YES forKey:@"sessionStart"];
            }
        }
        if (consentManagement != nil) {
            [tempDict setObject:consentManagement forKey:@"consentManagement"];
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
