//
//  ScreenPropertyBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderProperty.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScreenPropertyBuilder : NSObject {
    RudderProperty *property;
}

- (instancetype) setScreenName: (NSString*) screenName;
- (RudderProperty*) build;

@end

NS_ASSUME_NONNULL_END
