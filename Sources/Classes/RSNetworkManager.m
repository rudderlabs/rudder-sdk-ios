//
//  RSNetworkManager.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSNetworkManager.h"

@implementation RSNetworkManager

NSString* const STATUS = @"STATUS";
NSString* const RESPONSE = @"RESPONSE";

- (instancetype)initWithConfig:(RSConfig *) config andAuthToken:(NSString *) authToken andAnonymousIdToken:(NSString *) anonymousIdToken andDataResidencyManager:(RSDataResidencyManager *) dataResidencyManager {
    self = [super init];
    if(self){
        self->config = config;
        self->authToken = authToken;
        self->anonymousIdToken = anonymousIdToken;
        self->dataResidencyManager = dataResidencyManager;
        self->networkLock = [[NSLock alloc] init];
    }
    return self;
}

-(RSNetworkResponse*) sendNetworkRequest: (NSString*) payload toEndpoint:(ENDPOINT) endpoint withRequestMethod:(REQUEST_METHOD) method {
    RSNetworkResponse *result = [[RSNetworkResponse alloc] init];
    __weak RSNetworkResponse* weakResult = result;
    if (self->authToken == nil || [self->authToken isEqual:@""]) {
        [RSLogger logError:@"RSNetworkManager: sendNetworkRequest: WriteKey was in-correct. Aborting the network request"];
        weakResult.state = WRONG_WRITE_KEY;
        return weakResult;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *requestEndPoint = [self getRequestUrl:endpoint];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSNetworkManager: sendNetworkRequest: requestURL %@", requestEndPoint]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:requestEndPoint]];
    [urlRequest addValue:[[NSString alloc] initWithFormat:@"Basic %@", self->authToken] forHTTPHeaderField:@"Authorization"];
    if(method == GET) {
        [urlRequest setHTTPMethod:@"GET"];
    }
    else {
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest addValue:@"Application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest addValue:self->anonymousIdToken forHTTPHeaderField:@"AnonymousId"];
        NSData *httpBody = [payload dataUsingEncoding:NSUTF8StringEncoding];
        [urlRequest setHTTPBody:httpBody];
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        weakResult.statusCode = (long)httpResponse.statusCode;
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSNetworkManager: sendNetworkRequest: Request to url %@ is successful with statusCode %ld",requestEndPoint, weakResult.statusCode ]];
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (weakResult.statusCode == 200) {
            weakResult.state = NETWORK_SUCCESS;
            weakResult.responsePayload = responseString;
            weakResult.errorPayload = nil;
        } else {
            weakResult.errorPayload = responseString;
            weakResult.responsePayload = nil;
            if(weakResult.statusCode == 404) {
                weakResult.state = RESOURCE_NOT_FOUND;
            } else if (![weakResult.errorPayload isEqualToString:@""] && [[weakResult.errorPayload lowercaseString] rangeOfString:@"invalid write key"].location != NSNotFound) {
                [RSLogger logError:[[NSString alloc] initWithFormat:@"RSNetworkManager: sendNetworkRequest: Request to url %@ failed with statusCode %ld due to invalid write key",requestEndPoint, weakResult.statusCode ]];
                weakResult.state = WRONG_WRITE_KEY;
            } else {
                weakResult.state = NETWORK_ERROR;
            }
            [RSLogger logError:[[NSString alloc] initWithFormat:@"RSNetworkManager: sendNetworkRequest: Request to url %@ failed with statusCode %ld due to %@", requestEndPoint, weakResult.statusCode, weakResult.errorPayload]];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [networkLock lock];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [networkLock unlock];
    
#if !__has_feature(objc_arc)
    dispatch_release(semaphore);
#endif
    return weakResult;
}

- (NSString *) getRequestUrl:(ENDPOINT) endpoint {
    NSString* baseUrl = [self getBaseUrl:endpoint];
    NSString* path = [self getEndpointPath:endpoint];
    return [baseUrl stringByAppendingString:path];
}

- (NSString *) getBaseUrl: (ENDPOINT) endpoint {
    switch(endpoint) {
        case BATCH_ENDPOINT:            
        case TRANSFORM_ENDPOINT:
            return [self addSlashAtTheEnd:[self->dataResidencyManager getDataPlaneUrl]];
        case SOURCE_CONFIG_ENDPOINT:
            return [self addSlashAtTheEnd:self->config.controlPlaneUrl];
    }
}

- (NSString *) addSlashAtTheEnd:(NSString *) url {
    if([url hasSuffix:@"/"]) {
        return url;
    }
    return [url stringByAppendingString:@"/"];
}

- (NSString *) getEndpointPath: (ENDPOINT) endpoint {
    switch(endpoint) {
        case BATCH_ENDPOINT:
            return @"v1/batch";
        case TRANSFORM_ENDPOINT:
            return @"transform";
        case SOURCE_CONFIG_ENDPOINT:
            return [[NSString alloc] initWithFormat:@"sourceConfig?p=ios&v=%@", RS_VERSION];
    }
}
@end
