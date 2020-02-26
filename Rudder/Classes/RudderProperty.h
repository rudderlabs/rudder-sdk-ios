//
//  RudderProperty.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderProperty : NSObject {
    NSMutableDictionary<NSString*, NSObject*>* propertyDict;
}

- (NSDictionary<NSString*, NSObject*>* _Nullable) getPropertyDict;
- (BOOL) hasProperty: (NSString*) key;
- (NSObject* _Nullable) getProperty: (NSString*) key;
- (void) put: (NSString*) key value:(NSObject*) value;
- (instancetype) putValue: (NSString*) key value:(NSObject*) value;
-(instancetype) putValue: (NSDictionary*) dictValue;
-(void) putRevenue: (double) revenue;
-(void) putCurrency: (NSString*) currency;
@end

NS_ASSUME_NONNULL_END
