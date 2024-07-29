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
- (NSInteger)nextDelay {
    NSInteger delay = (NSInteger)pow(2, _attempt++);
    NSInteger jitter = arc4random_uniform((uint32_t)(delay + 1));
    
    NSInteger exponentialDelay = _initialDelay + delay + jitter;
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


