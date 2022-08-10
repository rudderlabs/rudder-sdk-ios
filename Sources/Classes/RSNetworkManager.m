//
//  RSNetworkManager.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSNetworkManager.h"

@implementation RSNetworkManager


- (instancetype)initWithConfig:(RSConfig *) config andAuthToken:(NSString *) authToken andAnonymousIdToken:(NSString *) anonymousIdToken {
    self = [super init];
    if(self){
        self->config = config;
        self->authToken = authToken;
        self->anonymousIdToken = anonymousIdToken;
        self->networkLock = [[NSLock alloc] init];
    }
    return self;
}

-(NSDictionary<NSString*, NSString*>*) sendNetworkRequest: (NSString*) payload toEndpoint:(ENDPOINT) endpoint {
    NSMutableDictionary<NSString*, NSString*>* responseDict = [[NSMutableDictionary alloc] init];
    if (self->authToken == nil || [self->authToken isEqual:@""]) {
        [RSLogger logError:@"WriteKey was not correct. Aborting flush to server"];
        responseDict[STATUS] = [[NSString alloc] initWithFormat:@"%d", WRONGWRITEKEY];
        return responseDict;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    int __block respStatus = NETWORKSUCCESS;
    NSString *requestEndPoint = nil;
    switch(endpoint) {
        case TRANSFORM_ENDPOINT:
            requestEndPoint = [self->config.dataPlaneUrl stringByAppendingString:@"/transform"];
            break;
        default:
            requestEndPoint = [@"https://e582-2409-4070-2e8f-e60d-94ce-840b-d457-d541.ngrok.io" stringByAppendingString:@"/v1/batch"];
            //requestEndPoint = [self->config.dataPlaneUrl stringByAppendingString:@"/v1/batch"];
    }
    
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"endPointToFlush %@", requestEndPoint]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:requestEndPoint]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"Application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:[[NSString alloc] initWithFormat:@"Basic %@", self->authToken] forHTTPHeaderField:@"Authorization"];
    dispatch_sync([RSContext getQueue], ^{
        [urlRequest addValue:self->anonymousIdToken forHTTPHeaderField:@"AnonymousId"];
    });
    NSData *httpBody = [payload dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:httpBody];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"statusCode %ld", (long)httpResponse.statusCode]];
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        responseDict[RESPONSE] = responseString;
        if (httpResponse.statusCode == 200) {
            respStatus = NETWORKSUCCESS;
            responseDict[STATUS] = [[NSString alloc] initWithFormat:@"%d", NETWORKSUCCESS];
        } else {
            if (
                ![responseString isEqualToString:@""] && // non-empty response
                [[responseString lowercaseString] rangeOfString:@"invalid write key"].location != NSNotFound
                ) {
                    respStatus = WRONGWRITEKEY;
                    responseDict[STATUS] = [[NSString alloc] initWithFormat:@"%d", WRONGWRITEKEY];
                } else {
                    respStatus = NETWORKERROR;
                    responseDict[STATUS] = [[NSString alloc] initWithFormat:@"%d", NETWORKERROR];
                }
            [RSLogger logError:[[NSString alloc] initWithFormat:@"ServerError: %@", responseString]];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    [networkLock lock];
    [dataTask resume];
    [networkLock unlock];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
#if !__has_feature(objc_arc)
    dispatch_release(semaphore);
#endif
    
    return responseDict;
}


@end
