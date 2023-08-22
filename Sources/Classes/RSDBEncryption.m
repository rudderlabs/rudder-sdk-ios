//
//  RSDBEncryption.m
//  Rudder
//
//  Created by Pallab Maiti on 09/08/23.
//

#import "RSDBEncryption.h"

@implementation RSDBEncryption

- (instancetype)initWithKey:(NSString *)key enable:(BOOL)enable {
    self = [super init];
    if (self) {
        self.key = key;
        self.enable = enable;
    }
    return self;
}

@end
