//
//  RSUserSession.h
//  Rudder
//
//  Created by Pallab Maiti on 27/07/22.
//

#import <Foundation/Foundation.h>
#import "RSClient.h"

NS_ASSUME_NONNULL_BEGIN

@class RSClient;

@interface RSUserSession : NSObject {
    RSClient *client;
    NSString *sessionId;
    BOOL sessionStart;
    NSDate *sessionStartTime;
}

+ (instancetype)initiate:(RSClient *)client;

- (void)startSession:(NSString *)sessionId;
- (void)sessionStart:(BOOL)sessionStart;
- (void)checkSessionDuration;
- (void)clearSession;

- (NSString *)getSessionId;
- (BOOL)getSessionStart;

@end

NS_ASSUME_NONNULL_END
