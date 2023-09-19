//
//  RSDBEncryption.m
//  Rudder
//
//  Created by Pallab Maiti on 09/08/23.
//

#import "RSDBEncryption.h"

@implementation RSDBEncryption

- (instancetype)initWithKey:(NSString *)key enable:(BOOL)enable databaseProvider:(id<RSDatabaseProvider>)databaseProvider {
    self = [super init];
    if (self) {
        self.key = key;
        self.enable = enable;
        self.databaseProvider = databaseProvider;
    }
    return self;
}

@end
