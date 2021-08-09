//
//  _CustomFactory.h
//  Rudder
//
//  Created by Abhishek Pandey on 09/08/21.
//  Copyright © 2021 arnabp92. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>

NS_ASSUME_NONNULL_BEGIN

@interface _CustomFactory : NSObject<RSIntegrationFactory>

+ (instancetype) instance;

@end

NS_ASSUME_NONNULL_END



