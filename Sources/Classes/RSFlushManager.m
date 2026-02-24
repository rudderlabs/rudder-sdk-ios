//
//  RSFlushManager.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSLogger.h"
#import "RSConfig.h"
#import "RSFlushManager.h"
#import "RSDBPersistentManager.h"
#import "RSNetworkResponse.h"

@implementation RSFlushManager

- (instancetype)initWithConfig:(RSConfig *)config andPersistentManager:(RSDBPersistentManager *)dbPersistentManager andNetworkManager:(RSNetworkManager *) networkManager andLock:(NSLock *) lock {
    self = [super init];
    if(self) {
        self->dbPersistentManager = dbPersistentManager;
        self->networkManager = networkManager;
        self->config = config;
        self->lock = lock;
        self->queue = dispatch_queue_create("com.rudder.flushQueue", NULL);
        self->source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, queue);
    }
    return self;
}

- (void) setUpFlush {
    __weak RSFlushManager *weakSelf = self;
    dispatch_source_set_event_handler(source, ^{
        RSFlushManager* strongSelf = weakSelf;
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSFlushUtils: setUpFlush: coalesce %lu calls into a single flush call", dispatch_source_get_data(strongSelf->source)]];
        [strongSelf flushSync];
    });
    dispatch_resume(self->source);
}

- (void)flush {
    dispatch_source_merge_data(self->source, 1);
}

- (void)flushSync {
    [lock lock];
    [self->dbPersistentManager clearOldEventsWithThreshold: self->config.dbCountThreshold];
    [RSLogger logDebug:@"RSFlushUtils: flushSync: Fetching events to flush to server in flush"];
    RSDBMessage* _dbMessage = [self->dbPersistentManager fetchAllEventsFromDBForMode:CLOUDMODE];
    int numberOfBatches = [RSUtils getNumberOfBatches:_dbMessage withFlushQueueSize:self->config.flushQueueSize];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSFlushUtils: flushSync: %d batches of events to be flushed", numberOfBatches]];
    BOOL lastBatchFailed = NO;
    for(int i=1; i<= numberOfBatches; i++) {
        lastBatchFailed = YES;
        int retries = 3;
        while(retries-- > 0) {
            NSMutableArray<NSString *>* messages = [RSUtils getBatch:_dbMessage.messages withQueueSize:self->config.flushQueueSize];
            NSMutableArray<NSString *>* messageIds = [RSUtils getBatch:_dbMessage.messageIds withQueueSize:self->config.flushQueueSize];
            RSDBMessage *batchDBMessage = [[RSDBMessage alloc] init];
            batchDBMessage.messageIds = messageIds;
            batchDBMessage.messages = messages;
            NSString* payload = [RSCloudModeManager getPayloadFromMessages:batchDBMessage];
            if (payload != nil) {
                RSNetworkResponse* response = [self->networkManager sendNetworkRequest:payload toEndpoint:BATCH_ENDPOINT withRequestMethod:POST];
                if( response.state == NETWORK_SUCCESS){
                    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSFlushUtils: flushSync: Successfully sent batch %d/%d", i, numberOfBatches]];
                    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSFlushUtils: flushSync: Clearing events of batch %d from DB", i]];
                    [self->dbPersistentManager updateEventsWithIds:batchDBMessage.messageIds withStatus:CLOUD_MODE_PROCESSING_DONE];
                    [self->dbPersistentManager clearProcessedEventsFromDB];
                    [_dbMessage.messages removeObjectsInArray:messages];
                    [_dbMessage.messageIds removeObjectsInArray:messageIds];
                    lastBatchFailed = NO;
                    break;
                }
            }
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSFlushUtils: flushSync: Failed to send %d/%d, retrying again, %d retries left", i, numberOfBatches, retries]];
        }
        if(lastBatchFailed) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSFlushUtils: flushSync: Failed to send %d/%d batch after 3 retries, dropping the remaining batches as well", i, numberOfBatches]];
            break;
        }
    }
    [lock unlock];
}
@end
