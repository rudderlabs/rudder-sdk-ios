//
//  RudderProperty.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderProperty.h"

@implementation RudderProperty

- (NSDictionary<NSString *,NSObject *> *)getPropertyDict {
    return self->propertyDict;
}

- (BOOL)hasProperty:(NSString *)key {
    if (self->propertyDict == nil) {
        return NO;
    }
    return [self ->propertyDict valueForKey:key] != nil;
}

- (NSObject *)getProperty:(NSString *)key {
    if (self->propertyDict == nil) {
        return nil;
    }
    return [self->propertyDict valueForKey:key];
}

- (void)put:(NSString *)key value:(NSObject *)value {
    if (self->propertyDict == nil) {
        self->propertyDict = [[NSMutableDictionary alloc] init];
    }
    [self->propertyDict setValue:value forKey:key];
}

- (instancetype)putValue:(NSString *)key value:(NSObject *)value {
    [self put:key value:value];
    return self;
}

- (instancetype)putValue:(NSDictionary *)dictValue {
    if (self->propertyDict == nil) {
        self->propertyDict = [[NSMutableDictionary alloc] init];
    }
    [self->propertyDict setDictionary:dictValue];
    return self;
}

- (void)putRevenue:(double)revenue {
    if (self->propertyDict == nil) {
        self->propertyDict = [[NSMutableDictionary alloc] init];
    }
    [self->propertyDict setValue:[[NSNumber alloc] initWithDouble:revenue] forKey:@"revenue"];
}

- (void) putCurrency:(NSString *)currency {
    if (self->propertyDict == nil) {
        self->propertyDict = [[NSMutableDictionary alloc] init];
    }
    [self->propertyDict setValue:currency forKey:@"currency"];
}

@end
