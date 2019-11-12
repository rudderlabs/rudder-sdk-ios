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

- (instancetype)init: (NSString*) _writeKey
{
    self = [super init];
    if (self) {
        userDefaults = [NSUserDefaults standardUserDefaults];
        if (_writeKey == nil || [_writeKey isEqualToString:@""]) {
            [RudderLogger logError:@"writeKey can not be null or empty"];
        } else {
            self->_writeKey = _writeKey;
            self->_serverConfig = [self _retrieveConfig];
            if (self->_serverConfig == nil || [self _isServerConfigOutDated]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                    [self _downloadConfig];
                });
            }
        }
    }
    return self;
}

+ (instancetype) getInstance: (NSString*) writeKey {
    if (_instance == nil) {
        _instance = [[RudderServerConfigManager alloc] init:writeKey];
    }
    return _instance;
}

- (BOOL) _isServerConfigOutDated {
    long currentTime = [Utils getTimeStampLong];
    long lastUpdatedTime = [userDefaults integerForKey:@"rl_server_update_time"];
    
    return (currentTime - lastUpdatedTime) > (24 * 60 * 60 * 1000);
}

- (RudderServerConfigSource*) _retrieveConfig {
    NSString* configStr = [userDefaults stringForKey:@"rl_server_config"];
    
    if (configStr == nil) {
        return nil;
    } else {
        return [self _parseConfig:configStr];
    }
}

//TODO
- (RudderServerConfigSource *)_parseConfig:(NSString *)configStr {
    NSError *error;
    NSDictionary *configDict = [NSJSONSerialization JSONObjectWithData:[configStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    RudderServerConfigSource *source;
    if (error == nil && configDict != nil) {
        NSDictionary *sourceDict = [configDict objectForKey:@"source"];
        NSString *sourceId = [sourceDict objectForKey:@"id"];
        NSString *sourceName = [sourceDict objectForKey:@"name"];
        BOOL isSourceEnabled = [sourceDict objectForKey:@"enabled"];
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
            destination.isDestinationEnabled =[destinationDict objectForKey:@"enabled"];
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
            
            isDone = YES;
        } else {
            retryCount += 1;
            usleep(10000000 * retryCount);
        }
    }
}

- (NSString *)_networkRequest {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *responseStr = nil;
    NSString *configUrl = [@"https://api.rudderlabs.com/source-config?write_key=" stringByAppendingString:self->_writeKey];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:configUrl]];
    NSData *authData = [[[NSString alloc] initWithFormat:@"%@:", self->_writeKey] dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest addValue:[[NSString alloc] initWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
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

- (RudderServerConfigSource *)getConfig {
    if (self->_serverConfig == nil) {
        self->_serverConfig = [self _retrieveConfig];
    }
    return self->_serverConfig;
}

@end
