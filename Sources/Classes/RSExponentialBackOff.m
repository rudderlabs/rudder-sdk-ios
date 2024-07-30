//
//  RSExponentialBackOff.m
//  Rudder
//
//  Created by Satheesh Kannan on 23/07/24.
//

#import "RSExponentialBackOff.h"

#pragma mark - RSExponentialBackOff

@interface RSExponentialBackOff()
@property (nonatomic, assign) NSInteger attempt;
@property (nonatomic, assign) NSInteger maximumDelay;
@property (nonatomic, assign) NSInteger initialDelay;
@end

@implementation RSExponentialBackOff

/**
 * Init function that accepts the maximum delay value in seconds.
 */
- (instancetype)initWithMaximumDelay:(int) seconds {
    self = [super init];
    if (self) {
        _maximumDelay = seconds;
        _attempt = 0;
        _initialDelay = 3;
    }
    
    return self;
}

/**
 * Function will calculate the next delay value in seconds
 */
- (int)nextDelay {
    int delay = pow(2, _attempt++);
    int jitter = arc4random_uniform((delay + 1));
    
    int exponentialDelay = _initialDelay + delay + jitter;
    exponentialDelay = MIN(exponentialDelay, _maximumDelay);
    
    if (exponentialDelay >= _maximumDelay) {
        _attempt = 0;
    }
    
    return exponentialDelay;
}

/**
 * Function will resets the attempts.
 */
- (void)reset {
    _attempt = 0;
}

@end


