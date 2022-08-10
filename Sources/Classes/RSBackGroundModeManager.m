//
//  RSBackGroundModeManager.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSBackGroundModeManager.h"

@implementation RSBackGroundModeManager

- (instancetype)initWithConfig:(RSConfig *) config {
    self = [super init];
    if(self){
        self->config = config;
        [RSLogger logDebug:@"RSBackGroundModeManager: Init: Initializing BackgroundMode Manager"];
#if !TARGET_OS_WATCH
        self->backgroundTask = UIBackgroundTaskInvalid;
#endif
        [self registerForBackGroundMode];
    }
    return self;
}


- (void) registerForBackGroundMode {
    if(self->config.enableBackgroundMode) {
#if !TARGET_OS_WATCH
        [self registerBackGroundTask];
#else
        [self askForAssertionWithSemaphore];
#endif
    }
}

#if !TARGET_OS_WATCH
/*
 Methods useful for registering for Background Run Time after the app has been backgrounded for the platforms iOS, tvOS
 */
- (void) registerBackGroundTask {
    if(backgroundTask != UIBackgroundTaskInvalid) {
        [self endBackGroundTask];
    }
    [RSLogger logDebug:@"RSBackGroundModeManager: registerBackGroundTask: Registering for Background Mode"];
    __weak RSBackGroundModeManager *weakSelf = self;
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        RSBackGroundModeManager *strongSelf = weakSelf;
        [strongSelf endBackGroundTask];
    }];
}

- (void) endBackGroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
    backgroundTask = UIBackgroundTaskInvalid;
}

#else

/*
 Methods useful for registering for Background Run Time after the app has been backgrounded for the platform watchOS
 */
- (void) askForAssertionWithSemaphore {
    if(self->semaphore == nil) {
        self->semaphore = dispatch_semaphore_create(0);
    } else if (!self->isSemaphoreReleased) {
        [self releaseAssertionWithSemaphore];
    }
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo performExpiringActivityWithReason:@"backgroundRunTime" usingBlock:^(BOOL expired) {
        if (expired) {
            [self releaseAssertionWithSemaphore];
            self->isSemaphoreReleased = YES;
        } else {
            [RSLogger logDebug:@"RSBackGroundModeManager: askForAssertionWithSemaphore: Asking Semaphore for Assertion to wait forever for backgroundMode"];
            self->isSemaphoreReleased = NO;
            dispatch_semaphore_wait(self->semaphore, DISPATCH_TIME_FOREVER);
        }
    }];
}

- (void) releaseAssertionWithSemaphore {
    [RSLogger logDebug:@"RSBackGroundModeManager: releaseAssertionWithSemaphore: Releasing Assertion on Semaphore for backgroundMode"];
    dispatch_semaphore_signal(self->semaphore);
}
#endif

@end
