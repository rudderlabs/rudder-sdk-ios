//
//  WKInterfaceController+RSScreen.h
//  Rudder
//
//  Created by Desu Sai Venkat on 15/12/21.
//

#include <TargetConditionals.h>
#if TARGET_OS_WATCH
#import <WatchKit/WatchKit.h>

@interface WKInterfaceController (RSScreen)

+ (void) rudder_swizzleView;

@end
#endif


