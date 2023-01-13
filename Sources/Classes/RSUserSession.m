//
//  RSUserSession.m
//  Rudder
//
//  Created by Pallab Maiti on 27/07/22.
//

#import "RSUserSession.h"
#import "RSLogger.h"
#import "RSUtils.h"

@implementation RSUserSession

static RSUserSession* _instance;
static dispatch_queue_t queue;

+ (instancetype) initiate:(long)sessionInActivityTimeOut with:(RSPreferenceManager *) preferenceManager {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init:sessionInActivityTimeOut with:preferenceManager];
        });
    }
    return _instance;
}

- (instancetype) init:(long)sessionInActivityTimeOut with:(RSPreferenceManager *) preferenceManager {
    self = [super init];
    if (self) {
        if (queue == nil) {
            queue = dispatch_queue_create("com.rudder.RSUserSession", NULL);
        }
        self->sessionInActivityTimeOut = sessionInActivityTimeOut;
        self->preferenceManager = preferenceManager;
        self->sessionId = [self->preferenceManager getSessionId];
        self->lastEventTimeStamp = [self->preferenceManager getLastEventTimeStamp];
    }
    return self;
}

- (void) startSession {
    [self startSession:[RSUtils getTimeStampLong]];
}

- (void) startSession:(long)sessionId {
    dispatch_sync(queue, ^{
        self->sessionId = [[NSNumber alloc] initWithLong:sessionId];
        [self->preferenceManager saveSessionId:self->sessionId];
        self->sessionStart = YES;
        [RSLogger logDebug:[NSString stringWithFormat:@"RSUserSession: startSession: Starting new session with id: %ld", sessionId]];
    });
}

- (void) startSessionIfExpired {
    if([self isSessionExpired]) {
        [RSLogger logDebug:@"RSUserSession: startSessionIfExpired: Session Expired due to In-activity, hence starting a new session"];
        [self refreshSession];
        return;
    }
    [RSLogger logDebug:@"RSUserSession: startSessionIfExpired: Previous session is still active, continuing with it"];
}

- (BOOL) isSessionExpired {
    if(self->lastEventTimeStamp == nil)
        return YES;
    __block NSTimeInterval timeDifference;
    dispatch_sync(queue, ^{
        timeDifference = labs([RSUtils getTimeStampLong] - [self->lastEventTimeStamp longValue]);
    });
    if (timeDifference > (self->sessionInActivityTimeOut / 1000)) {
        return YES;
    }
    return NO;
}

- (void) refreshSession {
    [self clearSession];
    [self startSession];
}

- (void) clearSession {
    [RSLogger logDebug:@"RSUserSession: clearSession: Resetting the session"];
    dispatch_sync(queue, ^{
        self->sessionId = nil;
        self->sessionStart = NO;
        self->lastEventTimeStamp = nil;
        [self->preferenceManager clearSessionId];
        [self->preferenceManager clearLastEventTimeStamp];
    });
}

- (NSNumber * __nullable) getSessionId {
    if(self->sessionId == nil)
        return nil;
    __block NSNumber *sessionId;
    dispatch_sync(queue, ^{
        sessionId = self->sessionId;
    });
    return sessionId;
}

- (BOOL) getSessionStart {
    __block BOOL sessionStart;
    dispatch_sync(queue, ^{
        sessionStart = self->sessionStart;
    });
    return sessionStart;
}

- (void) setSessionStart:(BOOL)sessionStart {
    dispatch_sync(queue, ^{
        self->sessionStart = sessionStart;
    });
}

- (void) updateLastEventTimeStamp {
    dispatch_sync(queue, ^{
        self->lastEventTimeStamp = [[NSNumber alloc] initWithLong:[RSUtils getTimeStampLong]];
        [self->preferenceManager saveLastEventTimeStamp:lastEventTimeStamp];
    });
}
@end
