//
//  RSDeviceModeManager.h
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSConfig.h"
#import "RSEnums.h"
#import "RSUtils.h"
#import "RSServerConfigSource.h"


@interface RSDataResidencyManager : NSObject {
    RSConfig* rudderConfig;
    NSString* dataResidencyUrl;
}

- (instancetype)initWithRSConfig:(RSConfig*) rudderConfig;
- (void)setDataResidencyUrlFromSourceConfig:(RSServerConfigSource*) sourceConfig;
- (NSString*) getDataPlaneUrl;
@end
