//
//  ScreenPropertyBuilder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSScreenPropertyBuilder.h"
#import "RSLogger.h"

@implementation RSScreenPropertyBuilder

- (instancetype)setScreenName:(NSString *)screenName {
    if (self->property == nil) {
        self->property = [[RSProperty alloc] init];
    }
    [self->property put:@"name" value:screenName];
    return self;
}

- (RSProperty *)build {
    if (self->property == nil) {
        [RSLogger logError:@"screen name is not set. returning blank"];
        self->property = [[RSProperty alloc] init];
    }
    return self->property;
}

@end
