//
//  RSDatabaseProvider.h
//  Rudder
//
//  Created by Pallab Maiti on 13/09/23.
//

#import <Foundation/Foundation.h>
#import "RSDatabase.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RSDatabaseProvider

- (id<RSDatabase>)getDatabase;

@end

NS_ASSUME_NONNULL_END
