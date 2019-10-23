//
//  RudderMessageBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderMessage.h"
#import "RudderProperty.h"
#import "RudderOption.h"

NS_ASSUME_NONNULL_BEGIN

@interface RudderMessageBuilder : NSObject {
    RudderMessage* message;
}

- (instancetype) setEventName: (NSString*) eventName;
- (instancetype) setUserId: (NSString*) userId;
- (instancetype) setPropertyDict: (NSDictionary<NSString*, NSObject*>*) property;
- (instancetype) setProperty: (RudderProperty*) property;
- (instancetype) setUserProperty: (NSDictionary<NSString*, NSObject*>*) userProperty;
- (instancetype) setRudderOption: (RudderOption*) option;
- (instancetype) setTraits: (RudderTraits*) traits;

- (RudderMessage*) build;

@end

NS_ASSUME_NONNULL_END
