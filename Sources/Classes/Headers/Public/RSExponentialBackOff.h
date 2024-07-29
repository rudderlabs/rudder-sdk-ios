//
//  RSExponentialBackOff.h
//  Rudder
//
//  Created by Satheesh Kannan on 23/07/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*!
 @brief This class implements an exponential backoff strategy with jitter for handling retries.
 
 @discussion It allows for configurable maximum delay and includes methods to calculate the next delay with jitter and reset the backoff attempts. When the calculated delay reaches or exceeds the maximum delay limit, the backoff resets and starts again from beginning.
 */
@interface RSExponentialBackOff : NSObject

/**
 * Init function that accepts the maximum delay value in seconds.
 *
 * @param seconds Value for maximum delay property
 * @return A new instance for this class
 */
- (instancetype)initWithMaximumDelay:(int)seconds;

/**
 * Function will calculate the next delay value in seconds
 *
 * @return Next delay value in seconds
 */
- (NSInteger)nextDelay;

/**
 * Function will resets the attempts.
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
