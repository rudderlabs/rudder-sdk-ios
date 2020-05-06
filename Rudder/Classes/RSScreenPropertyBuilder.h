//
//  ScreenPropertyBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSProperty.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSScreenPropertyBuilder : NSObject {
    RSProperty *property;
}

- (instancetype) setScreenName: (NSString*) screenName;
- (RSProperty*) build;

@end

NS_ASSUME_NONNULL_END
