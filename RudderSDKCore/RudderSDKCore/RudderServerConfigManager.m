//
//  RudderServerConfigManager.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderServerConfigManager.h"
#import "Utils.h"
#import "RudderLogger.h"
#import "RudderServerDestination.h"

static RudderServerConfigManager *_instance;
NSUserDefaults *userDefaults;

@implementation RudderServerConfigManager

+ (instancetype)getInstance:(NSString *)writeKey rudderConfig:(RudderConfig *)rudderConfig {
    if (_instance == nil) {
        [RudderLogger logDebug:@"Creating RudderServerConfigManager instance"];
        _instance = [[RudderServerConfigManager alloc] init:writeKey rudderConfig:rudderConfig];
    }
    return _instance;
}

- (instancetype)init: (NSString*) _writeKey rudderConfig:(RudderConfig*) rudderConfig
{
    self = [super init];
    if (self) {
        userDefaults = [NSUserDefaults standardUserDefaults];
        if (_writeKey == nil || [_writeKey isEqualToString:@""]) {
            [RudderLogger logError:@"writeKey can not be null or empty"];
        } else {
            self->_writeKey = _writeKey;
            self->_rudderConfig = rudderConfig;
            self->_serverConfig = [self _retrieveConfig];
            if (self->_serverConfig == nil) {
                [RudderLogger logDebug:@"Server config is not present in preference storage. downloading config"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                    [self _downloadConfig];
                });
            } else {
                if([self _isServerConfigOutDated]) {
                    [RudderLogger logDebug:@"Server config is outdated. downloading config again"];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        [self _downloadConfig];
                    });
                } else {
                    [RudderLogger logDebug:@"Server config found. Using existing config"];
                }
            }
        }
    }
    return self;
}

- (BOOL) _isServerConfigOutDated {
    long currentTime = [Utils getTimeStampLong];
    long lastUpdatedTime = [userDefaults integerForKey:@"rl_server_update_time"];
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Last updated config time: %ld", lastUpdatedTime]];
    return (currentTime - lastUpdatedTime) > (self->_rudderConfig.configRefreshInterval * 60 * 60 * 1000);
}

- (RudderServerConfigSource*) _retrieveConfig {
    NSString* configStr = [userDefaults stringForKey:@"rl_server_config"];
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"configJson: %@", configStr]];
    if (configStr == nil) {
        return nil;
    } else {
        return [self _parseConfig:configStr];
    }
}

- (RudderServerConfigSource *)_parseConfig:(NSString *)configStr {
    NSError *error;
    NSDictionary *configDict = [NSJSONSerialization JSONObjectWithData:[configStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    RudderServerConfigSource *source;
    if (error == nil && configDict != nil) {
        NSDictionary *sourceDict = [configDict objectForKey:@"source"];
        NSString *sourceId = [sourceDict objectForKey:@"id"];
        NSString *sourceName = [sourceDict objectForKey:@"name"];
        NSNumber *sourceEnabled = [sourceDict valueForKey:@"enabled"];
        BOOL isSourceEnabled = NO;
        if (sourceEnabled != nil) {
           isSourceEnabled = [sourceEnabled boolValue];
        }
        NSString *updatedAt = [sourceDict objectForKey:@"updatedAt"];
        source = [[RudderServerConfigSource alloc] init];
        source.sourceId = sourceId;
        source.sourceName = sourceName;
        source.isSourceEnabled = isSourceEnabled;
        source.updatedAt = updatedAt;
        
        NSArray *destinationArr = [sourceDict objectForKey:@"destinations"];
        NSMutableArray *destinations = [[NSMutableArray alloc] init];
        for (NSDictionary* destinationDict in destinationArr) {
            // create destination object
            RudderServerDestination *destination = [[RudderServerDestination alloc] init];
            destination.destinationId = [destinationDict objectForKey:@"id"];
            destination.destinationName = [destinationDict objectForKey:@"name"];
            NSNumber *destinationEnabled = [destinationDict objectForKey:@"enabled"];
            BOOL isDestinationEnabled = NO;
            if (destinationEnabled != nil) {
                isDestinationEnabled = [destinationEnabled boolValue];
            }
            destination.isDestinationEnabled = isDestinationEnabled;
            destination.updatedAt = [destinationDict objectForKey:@"updatedAt"];
            
            RudderServerDestinationDefinition *destinationDefinition = [[RudderServerDestinationDefinition alloc] init];
            NSDictionary *definitionDict = [destinationDict objectForKey:@"destinationDefinition"];
            destinationDefinition.definitionName = [definitionDict objectForKey:@"name"];
            destinationDefinition.displayName = [definitionDict objectForKey:@"displayName"];
            destinationDefinition.updatedAt = [definitionDict objectForKey:@"updatedAt"];
            
            destination.destinationDefinition = destinationDefinition;
            
            destination.destinationConfig = [destinationDict objectForKey:@"config"];
            [destinations addObject:destination];
        }
        source.destinations = destinations;
    } else {
        [RudderLogger logError:@"config deserializaion error"];
    }
    
    return source;
}

- (void)_downloadConfig {
    BOOL isDone = NO;
    int retryCount = 0;
    while (isDone == NO && retryCount <= 3) {
        NSString* configJson = [self _networkRequest];
        
        if (configJson != nil) {
            [userDefaults setObject:configJson forKey:@"rl_server_config"];
            [userDefaults setObject:[[NSNumber alloc] initWithDouble:[Utils getTimeStampLong]] forKey:@"rl_server_update_time"];
            
            self->_serverConfig = [self _parseConfig:configJson];
            
            [RudderLogger logDebug:@"server config download successful"];
            
            isDone = YES;
        } else {
            retryCount += 1;
            [RudderLogger logInfo:[[NSString alloc] initWithFormat:@"Retrying download in %d seconds", (10 * retryCount)]];
            usleep(10000000 * retryCount);
        }
    }
}

- (NSString *)_networkRequest {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *responseStr = nil;
    NSString *configUrl = @"https://api.rudderlabs.com/sourceConfig";
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"configUrl: %@", configUrl]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:configUrl]];
    NSData *authData = [[[NSString alloc] initWithFormat:@"%@:", self->_writeKey] dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest addValue:[[NSString alloc] initWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"response status code: %ld", (long)httpResponse.statusCode]];
        
        if (httpResponse.statusCode == 200) {
            if (data != nil) {
                responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"configJson: %@", responseStr]];
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

- (RudderServerConfigSource *)getConfig {
    if (self->_serverConfig == nil) {
        self->_serverConfig = [self _retrieveConfig];
    }
    return self->_serverConfig;
}

@end
