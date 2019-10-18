//
//  RudderDBMessage.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 18/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderDBMessage : NSObject
    @property (nonatomic) NSArray<NSString *>* messages;
    @property (nonatomic) NSArray<NSString *>* messageIds;
@end

NS_ASSUME_NONNULL_END
