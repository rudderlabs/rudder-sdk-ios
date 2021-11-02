//
//  _CustomIntegration.h
//  Rudder
//
//  Created by Abhishek Pandey on 09/08/21.
//  Copyright © 2021 arnabp92. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomIntegration : NSObject<RSIntegration>

@property (nonatomic, strong) NSDictionary *config;
@property (nonatomic, strong) RSClient *client;

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client;

@end

NS_ASSUME_NONNULL_END

