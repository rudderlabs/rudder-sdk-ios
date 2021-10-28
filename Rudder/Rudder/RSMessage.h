//
//  RSMessage.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSContext.h"
#import "RSOption.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSMessage : NSObject

@property (atomic, readwrite) NSString* messageId;
@property (atomic, readwrite) NSString* channel;
@property (atomic, readwrite) RSContext* context;
@property (atomic, readwrite) NSString* type;
@property (atomic, readwrite) NSString* action;
@property (atomic, readwrite) NSString* originalTimestamp;
@property (atomic, readwrite) NSString* anonymousId;
@property (atomic, readwrite) NSString* userId;
@property (atomic, readwrite) NSString* previousId;
@property (atomic, readwrite) NSString* groupId;
@property (atomic, readwrite) NSDictionary* traits;
@property (atomic, readwrite) NSString* event;
@property (atomic, readwrite) NSDictionary<NSString *, NSObject *>* properties;
@property (atomic, readwrite) NSDictionary<NSString *, NSObject *>* userProperties;
@property (atomic, readwrite) NSDictionary<NSString *, NSObject *>* integrations;
@property (atomic, readwrite) NSDictionary<NSString*, NSDictionary<NSString*, id>*>* customContexts;
@property (atomic, readwrite) NSString* destinationProps;
@property (atomic, readwrite) RSOption* option;

- (NSDictionary<NSString*, NSObject*>*) dict;
- (void) updateContext: (RSContext*) context;
- (void) updateTraits: (RSTraits*) traits;
- (void) updateTraitsDict:(NSMutableDictionary<NSString *,NSObject *>*)traits;
- (void) setRudderOption: (RSOption*) option;

@end

NS_ASSUME_NONNULL_END
