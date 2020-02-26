//
//  RudderApp.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderApp : NSObject

- (NSDictionary<NSString* , NSObject *>*) dict;

@property (nonatomic, readwrite) NSString* build;
@property (nonatomic, readwrite) NSString* name;
@property (nonatomic, readwrite) NSString* nameSpace;
@property (nonatomic, readwrite) NSString* version;

@end

NS_ASSUME_NONNULL_END
