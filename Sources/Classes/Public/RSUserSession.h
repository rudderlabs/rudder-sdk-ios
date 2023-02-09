//
//  RSUserSession.h
//  Rudder
//
//  Created by Pallab Maiti on 27/07/22.
//

#import <Foundation/Foundation.h>
#import "RSPreferenceManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface RSUserSession : NSObject {
    long sessionInActivityTimeOut;
    NSNumber *sessionId;
    BOOL sessionStart;
    NSNumber *lastEventTimeStamp;
    RSPreferenceManager* preferenceManager;
}

+ (instancetype) initiate:(long)sessionInActivityTimeOut with:(RSPreferenceManager *) preferenceManager;

- (void)startSession;
- (void)startSession:(long)sessionId;
- (void)setSessionStart:(BOOL)sessionStart;
- (BOOL)isSessionExpired;
- (void)startSessionIfExpired;
- (void)refreshSession;
- (void)clearSession;
- (void)updateLastEventTimeStamp;
- (NSNumber * __nullable)getSessionId;
- (BOOL)getSessionStart;

@end

NS_ASSUME_NONNULL_END
