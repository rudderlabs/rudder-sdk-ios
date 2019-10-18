//
//  EventRepository.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "EventRepository.h"
#import "RudderElementCache.h"
#import "Utils.h"

static EventRepository* _instance;

@implementation EventRepository

+ (instancetype)initiate:(NSString *)writeKey config:(RudderConfig *)config {
    
    if (_instance == nil) {
        _instance = [[self alloc] init:writeKey config:config];
    }
    
    return _instance;
}

- (instancetype)init : (NSString*) _writeKey config:(RudderConfig*) _config
{
    self = [super init];
    if (self) {
        writeKey = _writeKey;
        config = _config;
        
        NSData *authData = [[[NSString alloc] initWithFormat:@"%@:", _writeKey] dataUsingEncoding:NSUTF8StringEncoding];
        authToken = [authData base64EncodedStringWithOptions:0];
        
        [RudderElementCache initiate];
        
        dbpersistenceManager = [[DBPersistentManager alloc] init];
        configManager = [[RudderServerConfigManager alloc] init];
        
        [self __initiateFactories];
        
        [self __initiateProcessor];
    }
    return self;
}

- (void) __initiateFactories {
    
}

- (void)__initiateProcessor {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"processor started");
        
        int sleepCount = 0;
        
        while (YES) {
            int recordCount = [self->dbpersistenceManager getDBRecordCount];
            if (recordCount > self->config.dbCountThreshold) {
                RudderDBMessage *dbMessage = [self->dbpersistenceManager fetchEventsFromDB:(recordCount - self->config.dbCountThreshold)];
                [self->dbpersistenceManager clearEventsFromDB:dbMessage.messageIds];
            }
            
            RudderDBMessage *dbMessage = [self->dbpersistenceManager fetchEventsFromDB:(self->config.flushQueueSize)];
            if (dbMessage.messages.count > 0 && (sleepCount >= self->config.sleepTimeout)) {
                NSString* payload = [self __getPayloadFromMessages:dbMessage.messages];
                if (payload != nil) {
                    NSString* response = [self __flushEventsToServer:payload];
                    if (response != nil && [response  isEqual: @"OK"]) {
                        [self->dbpersistenceManager clearEventsFromDB:dbMessage.messageIds];
                        sleepCount = 0;
                    }
                }
            }
            sleepCount += 1;
            usleep(1000000);
        }
    });
}

- (NSString*) __getPayloadFromMessages: (NSArray<NSString*>*) messages {
    NSString* sentAt = [Utils getTimestamp];
    
    NSMutableString* json = [[NSMutableString alloc] init];
    
    [json appendString:@"{"];
    [json appendFormat:@"\"sentAt\":\"%@\",", sentAt];
    [json appendString:@"\"batch\":["];
    for (int index = 0; index < messages.count; index++) {
        NSMutableString* message = [[NSMutableString alloc] initWithString:messages[index]];
        long length = message.length;
        message = [[NSMutableString alloc] initWithString:[message substringWithRange:NSMakeRange(0, (length-1))]];
        [message appendFormat:@",\"sentAt\":\"%@\"}", sentAt];
        [json appendString:message];
        if (index != messages.count-1) {
            [json appendString:@","];
        }
    }
    [json appendString:@"]}"];
    
    return [json copy];
}

- (NSString*) __flushEventsToServer: (NSString*) payload {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *responseStr = nil;
    NSString *endPointUrl = [self->config.endPointUrl stringByAppendingString:@"/v1/batch"];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:endPointUrl]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"Application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:[[NSString alloc] initWithFormat:@"Basic %@", self->authToken] forHTTPHeaderField:@"Authorization"];
    NSData *httpBody = [payload dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:httpBody];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        NSLog(@"status code: %ld", (long)httpResponse.statusCode);
        
        if (httpResponse.statusCode == 200) {
            if (data != nil) {
                responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
#if !__has_feature(objc_arc)
    dispatch_release(sema);
#endif
    
    return responseStr;
}

- (void) dump:(RudderMessage *)message {
    if (message == nil) return;
    
    if (self->integrations == nil) {
        [self __prepareIntegrations];
    }
    
    message.integrations = self->integrations;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[message dict] options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self->dbpersistenceManager saveEvent:jsonString];
}

- (void) __prepareIntegrations {
    self->integrations = [[NSMutableDictionary alloc] init];
    [self->integrations setValue:[NSNumber numberWithBool:YES] forKey:@"All"];
}

@end
