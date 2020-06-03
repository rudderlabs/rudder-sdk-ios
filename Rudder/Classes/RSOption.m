//
//  RSOption.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSOption.h"

NSMutableDictionary *_integrations;
NSMutableDictionary *_context;

@implementation RSOption




- (instancetype)init {
    self = [super init];
    if (self) {
        _integrations = [[NSMutableDictionary alloc] init];
        _context = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (NSMutableDictionary *) setIntegration:(NSString *) integrationKey
                                 enabled: (BOOL) enabled {
    _integrations = [[NSMutableDictionary alloc] init];
    _context = [[NSMutableDictionary alloc] init];
    
    NSString *enabledString;
    if(enabled){
        enabledString = @"true";
    }
    else{
        enabledString = @"false";
    }
    [_integrations setObject: (NSString *)enabledString  forKey:(integrationKey)];
    return _integrations;
}

+ (RSOption *) setIntegrationOptions: (NSString *) integrationKey
                            options : (NSDictionary *) options {
    
    _integrations = [[NSMutableDictionary alloc] init];
    _context = [[NSMutableDictionary alloc] init];
    [_integrations setObject:options forKey:(integrationKey)];
    return self;
}

+ (RSOption *) putContext: (NSString *) key
                    value: (NSObject *) value {
    
    _context = [[NSMutableDictionary alloc] init];
    _integrations = [[NSMutableDictionary alloc] init];
    
    [_context setObject:value forKey:(key)];
    return self;
}

+ (NSMutableDictionary *) integrations  {
    return _integrations;
}

+ (NSMutableDictionary *) context {
    return _context;
}
@end
