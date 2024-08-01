//
//  RSExponentialBackOff.m
//  Rudder
//
//  Created by Satheesh Kannan on 23/07/24.
//

#import "RSExponentialBackOff.h"
#import "RSConstants.h"
#pragma mark - RSExponentialBackOff

@interface RSExponentialBackOff()
@property (nonatomic, assign) int attempt;
@property (nonatomic, assign) int maximumDelay;
@property (nonatomic, assign) int initialDelay;
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
        _initialDelay = RSExponentialBackOff_InitialDelay;
    }
    
    return self;
}

/**
 * Function will calculate the next delay value in seconds
 */
- (int)nextDelay {
    int delay = _initialDelay * (int)pow(2, _attempt);
    _attempt = _attempt + 1;
    
    int jitter = arc4random_uniform((delay + 1));
    
    int exponentialDelay = delay + jitter;
    exponentialDelay = MIN(exponentialDelay, _maximumDelay);
    
    if (exponentialDelay == _maximumDelay) {
        [self reset];
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


