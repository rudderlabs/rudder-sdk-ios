//
//  RSEventFilteringPlugin.m
//  Rudder
//
//  Created by Desu Sai Venkat on 17/01/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSEventFilteringPlugin.h"

@implementation RSEventFilteringPlugin



- (instancetype)init: (NSArray*) destinations
{
    self = [super init];
    if (self) {
        self->eventFilteringOption = [[NSMutableDictionary alloc] init];
        self->blackListedEvents = [[NSMutableDictionary alloc] init];
        self->whiteListedEvents = [[NSMutableDictionary alloc] init];
        
        for (RSServerDestination *destination in destinations) {
            NSDictionary *destinationConfig = destination.destinationConfig;
            NSString *destinationName = destination.destinationDefinition.displayName;
            NSString *eventFilteringStatus = destinationConfig[EVENT_FILTERING_OPTION] ? destinationConfig[EVENT_FILTERING_OPTION] : DISABLE;
            if( ![eventFilteringStatus isEqualToString:DISABLE] && ! eventFilteringOption[destinationName] ) {
                eventFilteringOption[destinationName] = eventFilteringStatus;
                if ([eventFilteringStatus isEqualToString:WHITELISTED_EVENTS] && destinationConfig[WHITELISTED_EVENTS]) {
                    self->whiteListedEvents[destinationName] = [self getTrimmedEventNames:destinationConfig[WHITELISTED_EVENTS]];
                } else if ([eventFilteringStatus isEqualToString:BLACKLISTED_EVENTS] && destinationConfig[BLACKLISTED_EVENTS]) {
                    self->blackListedEvents[destinationName] = [self getTrimmedEventNames:destinationConfig[BLACKLISTED_EVENTS]];
                }
            }
        }
    }
    return self;
}

- (NSArray<NSString*>*) getTrimmedEventNames : (NSArray<NSDictionary<NSString*, NSString*>*>*) eventsList {
    NSMutableArray<NSString*>* trimmedEventNames = [[NSMutableArray alloc] init];
    for(NSDictionary* event in eventsList) {
        NSString* trimmedEventName = [event[EVENT_NAME] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(trimmedEventName != nil && trimmedEventName.length >0) {
            [trimmedEventNames addObject:trimmedEventName];
        }
    }
    return trimmedEventNames;
}

- (BOOL) isEventAllowed:(RSMessage *) message byDestination: (NSString *) destinationName; {
    if(message != nil && message.type != nil && message.type.length > 0 && [message.type isEqualToString:RSTrack] && message.event != nil && message.event.length >0 ) {
        if([self isEventFilteringEnabled:destinationName]) {
            BOOL isEventAllowed = NO;
            NSString* eventName = [message.event stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* eventFilteringType = eventFilteringOption[destinationName];
            if([eventFilteringType isEqualToString:WHITELISTED_EVENTS]) {
                isEventAllowed = whiteListedEvents[destinationName] != nil && [whiteListedEvents[destinationName] containsObject:eventName];
            } else {
                isEventAllowed = blackListedEvents[destinationName] != nil && ![blackListedEvents[destinationName] containsObject:eventName];
            }
            if(!isEventAllowed) {
                [RSLogger logInfo:[NSString stringWithFormat:@"RSEventFilterPlugin: isEventAllowed: Dropping the event %@ to the destination %@ as it is %@", eventName, destinationName, [eventFilteringType isEqualToString:WHITELISTED_EVENTS] ? @"not in white list" : @"in blacklist"]];
            }
            return isEventAllowed;
        }
    }
    return YES;
}

- (BOOL) isEventFilteringEnabled: (NSString*) destinationName {
    return eventFilteringOption[destinationName] ? YES : NO;
}

- (NSString*) getEventFilterType: (NSString*) destinationName {
    return eventFilteringOption[destinationName] ;
}

@end
