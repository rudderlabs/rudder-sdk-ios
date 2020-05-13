//
//  RSServerConfigManager.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSServerConfigManager.h"
#import "RSUtils.h"
#import "RSLogger.h"
#import "RSServerDestination.h"
#import "RSConstants.h"

static RSServerConfigManager *_instance;

@implementation RSServerConfigManager

+ (instancetype)getInstance:(NSString *)writeKey rudderConfig:(RSConfig *)rudderConfig {
    if (_instance == nil) {
        [RSLogger logDebug:@"Creating RSServerConfigManager instance"];
        _instance = [[RSServerConfigManager alloc] init:writeKey rudderConfig:rudderConfig];
    }
    return _instance;
}

- (instancetype)init: (NSString*) writeKey rudderConfig:(RSConfig*) rudderConfig
{
    self = [super init];
    if (self) {
        _preferenceManager = [RSPreferenceManager getInstance];
        if (writeKey == nil || [writeKey isEqualToString:@""]) {
            [RSLogger logError:@"writeKey can not be null or empty"];
        } else {
            _writeKey = writeKey;
            _rudderConfig = rudderConfig;
            RSServerConfigSource *serverConfig = [self _retrieveConfig];
            if (serverConfig == nil) {
                [RSLogger logDebug:@"Server config is not present in preference storage. downloading config"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                    [self _downloadConfig];
                });
            } else {
                if([self _isServerConfigOutDated]) {
                    [RSLogger logDebug:@"Server config is outdated. downloading config again"];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        [self _downloadConfig];
                    });
                } else {
                    [RSLogger logDebug:@"Server config found. Using existing config"];
                }
            }
        }
    }
    return self;
}

- (BOOL) _isServerConfigOutDated {
    long currentTime = [RSUtils getTimeStampLong];
    long lastUpdatedTime = [_preferenceManager getLastUpdatedTime];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Last updated config time: %ld", lastUpdatedTime]];
    return (currentTime - lastUpdatedTime) > (_rudderConfig.configRefreshInterval * 60 * 60 * 1000);
}

- (RSServerConfigSource* _Nullable) _retrieveConfig {
    NSString* configStr = [_preferenceManager getConfigJson];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"configJson: %@", configStr]];
    if (configStr == nil) {
        return nil;
    } else {
        return [self _parseConfig:configStr];
    }
}

- (RSServerConfigSource *)_parseConfig:(NSString *)configStr {
    NSError *error;
    NSDictionary *configDict = [NSJSONSerialization JSONObjectWithData:[configStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    RSServerConfigSource *source;
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
        source = [[RSServerConfigSource alloc] init];
        source.sourceId = sourceId;
        source.sourceName = sourceName;
        source.isSourceEnabled = isSourceEnabled;
        source.updatedAt = updatedAt;
        
        NSArray *destinationArr = [sourceDict objectForKey:@"destinations"];
        NSMutableArray *destinations = [[NSMutableArray alloc] init];
        for (NSDictionary* destinationDict in destinationArr) {
            // create destination object
            RSServerDestination *destination = [[RSServerDestination alloc] init];
            destination.destinationId = [destinationDict objectForKey:@"id"];
            destination.destinationName = [destinationDict objectForKey:@"name"];
            NSNumber *destinationEnabled = [destinationDict objectForKey:@"enabled"];
            BOOL isDestinationEnabled = NO;
            if (destinationEnabled != nil) {
                isDestinationEnabled = [destinationEnabled boolValue];
            }
            destination.isDestinationEnabled = isDestinationEnabled;
            destination.updatedAt = [destinationDict objectForKey:@"updatedAt"];
            
            RSServerDestinationDefinition *destinationDefinition = [[RSServerDestinationDefinition alloc] init];
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
        [RSLogger logError:@"config deserializaion error"];
    }
    
    return source;
}

- (void)_downloadConfig {
    BOOL isDone = NO;
    int retryCount = 0;
    while (isDone == NO && retryCount <= 3) {
        NSString* configJson = [self _networkRequest];
        
        if (configJson != nil) {
            [_preferenceManager saveConfigJson:configJson];
            [_preferenceManager updateLastUpdatedTime:[RSUtils getTimeStampLong]];
            
            [RSLogger logDebug:@"server config download successful"];
            
            isDone = YES;
        } else {
            retryCount += 1;
            [RSLogger logInfo:[[NSString alloc] initWithFormat:@"Retrying download in %d seconds", (10 * retryCount)]];
            usleep(10000000 * retryCount); 
        }
    }
}

- (NSString *)_networkRequest {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *responseStr = nil;
    NSString *controlPlaneEndPoint = [NSString stringWithFormat:@"%@/sourceConfig?p=ios&v=%@", _rudderConfig.controlPlaneUrl, RS_VERSION];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"configUrl: %@", controlPlaneEndPoint]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:controlPlaneEndPoint]];
    NSData *authData = [[[NSString alloc] initWithFormat:@"%@:", _writeKey] dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest addValue:[[NSString alloc] initWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"response status code: %ld", (long)httpResponse.statusCode]];
        
        if (httpResponse.statusCode == 200) {
            if (data != nil) {
                responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"configJson: %@", responseStr]];
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

- (RSServerConfigSource *) getConfig {
    return [self _retrieveConfig];
}

@end
