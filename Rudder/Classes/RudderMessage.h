//
//  RudderMessage.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface RudderMessage : NSObject

@property (atomic, readwrite) NSString* messageId;
@property (atomic, readwrite) NSString* channel;
@property (atomic, readwrite) RudderContext* context;
@property (atomic, readwrite) NSString* type;
@property (atomic, readwrite) NSString* action;
@property (atomic, readwrite) NSString* originalTimestamp;
@property (atomic, readwrite) NSString* anonymousId;
@property (atomic, readwrite) NSString* userId;
@property (atomic, readwrite) NSString* event;
@property (atomic, readwrite) NSDictionary<NSString *, NSObject *>* properties;
@property (atomic, readwrite) NSDictionary<NSString *, NSObject *>* userProperties;
@property (atomic, readwrite) NSDictionary<NSString *, NSObject *>* integrations;
@property (atomic, readwrite) NSString* destinationProps;

- (NSDictionary<NSString*, NSObject*>*) dict;
- (void) updateContext: (RudderContext*) context;
- (void) updateTraits: (RudderTraits*) traits;

@end

NS_ASSUME_NONNULL_END
