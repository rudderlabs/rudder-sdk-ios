//
//  ScreenPropertyBuilder.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "ScreenPropertyBuilder.h"
#import "RudderLogger.h"

@implementation ScreenPropertyBuilder

- (instancetype)setScreenName:(NSString *)screenName {
    if (self->property == nil) {
        self->property = [[RudderProperty alloc] init];
    }
    [self->property put:@"name" value:screenName];
    return self;
}

- (RudderProperty *)build {
    if (self->property == nil) {
        [RudderLogger logError:@"screen name is not set. returning blank"];
        self->property = [[RudderProperty alloc] init];
    }
    return self->property;
}

@end
