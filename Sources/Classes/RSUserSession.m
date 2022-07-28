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

+ (instancetype)initiate:(RSClient *)client {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init:client];
        });
    }
    return _instance;
}

- (instancetype)init:(RSClient *)client {
    self = [super init];
    if (self) {
        if (queue == nil) {
            queue = dispatch_queue_create("com.rudder.RSUserSession", NULL);
        }
        self->client = client;
    }
    return self;
}

- (void)startSession {
    [self startSession:[NSString stringWithFormat:@"%ld", [RSUtils getTimeStampLong]]];
}

- (void)startSession:(NSString *)sessionId {
    dispatch_sync(queue, ^{
        [self _startSession:sessionId];
    });
}

- (void)_startSession:(NSString *)sessionId {
    if ([client configuration].trackLifecycleEvents) {
        if ([sessionId length] > 0) {
            self->sessionId = sessionId;
            self->sessionStart = YES;
            self->sessionStartTime = [[NSDate alloc] init];
            [RSLogger logDebug:[NSString stringWithFormat:@"Starting new session with id: %@", sessionId]];
        } else {
            [RSLogger logDebug:@"sessionId can not be empty"];
        }
    } else {
        [RSLogger logDebug:@"Life cycle events tracking is off"];
    }
}


- (void)checkSessionDuration {
    dispatch_sync(queue, ^{
        NSTimeInterval timeDifference = fabs([[[NSDate alloc] init] timeIntervalSinceDate:self->sessionStartTime]);
        if (timeDifference > ([client configuration].sessionDuration * 60)) {
            [self _startSession:[NSString stringWithFormat:@"%ld", [RSUtils getTimeStampLong]]];
        }
    });
}

- (void)clearSession {
    dispatch_sync(queue, ^{
        self->sessionId = nil;
    });
}

- (NSString *)getSessionId {
    __block NSString *sessionId;
    dispatch_sync(queue, ^{
        sessionId = self->sessionId;
    });
    return sessionId;
}

- (BOOL)getSessionStart {
    __block BOOL sessionStart;
    dispatch_sync(queue, ^{
        sessionStart = self->sessionStart;
    });
    return sessionStart;
}

- (void)sessionStart:(BOOL)sessionStart {
    dispatch_sync(queue, ^{
        self->sessionStart = sessionStart;
    });
}

@end
