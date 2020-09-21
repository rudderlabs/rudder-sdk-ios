//
//  RSOption.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSOption : NSObject

@property (nonatomic, strong) NSMutableArray<NSMutableDictionary<NSString*, NSObject*>*>* externalIds;

- (instancetype) putExternalId: (NSString*) type withId: (NSString*) idValue;

@end

NS_ASSUME_NONNULL_END
