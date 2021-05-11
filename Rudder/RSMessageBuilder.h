//
//  RSMessageBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSMessage.h"
#import "RSProperty.h"
#import "RSOption.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSMessageBuilder : NSObject {
    RSMessage* message;
}

- (instancetype) setEventName: (NSString*) eventName;
- (instancetype) setUserId: (NSString*) userId;
- (instancetype) setPreviousId: (NSString*) previousId;
- (instancetype) setGroupId: (NSString*) groupId;
- (instancetype) setGroupTraits: (NSDictionary *) groupTraits;
- (instancetype) setPropertyDict: (NSDictionary<NSString*, NSObject*>*) property;
- (instancetype) setProperty: (RSProperty*) property;
- (instancetype) setUserProperty: (NSDictionary<NSString*, NSObject*>*) userProperty;
- (instancetype) setRSOption: (RSOption*) option;
- (instancetype) setTraits: (RSTraits*) traits;
- (instancetype) setIntegrations:(NSDictionary<NSString *, NSObject *>*) integrations;

- (RSMessage*) build;

@end

NS_ASSUME_NONNULL_END
