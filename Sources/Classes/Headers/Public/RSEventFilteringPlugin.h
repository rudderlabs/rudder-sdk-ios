//
//  RSEventFilteringPlugin.h
//  Rudder
//
//  Created by Desu Sai Venkat on 17/01/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSMessage.h"
#import "RSServerDestination.h"
#import "RSMessageType.h"
#import "RSLogger.h"
#import "RSConstants.h"

@interface RSEventFilteringPlugin : NSObject {
    NSMutableDictionary<NSString*, NSString*>* eventFilteringOption;
    NSMutableDictionary<NSString*, NSArray<NSString*>*>* whiteListedEvents;
    NSMutableDictionary<NSString*, NSArray<NSString*>*>* blackListedEvents;
}

- (instancetype)init: (NSArray*) destinations;
- (BOOL) isEventAllowed: (NSString*) destinationName withMessage: (RSMessage*) message;

@end
