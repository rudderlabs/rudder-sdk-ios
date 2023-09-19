//
//  RSDefaultDatabaseProvider.m
//  Rudder
//
//  Created by Pallab Maiti on 14/09/23.
//

#import "RSDefaultDatabaseProvider.h"
#import "RSDefaultDatabase.h"

@implementation RSDefaultDatabaseProvider

- (id<RSDatabase>)getDatabase {
    return [RSDefaultDatabase new];
}

@end
