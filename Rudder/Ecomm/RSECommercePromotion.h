//
//  RSECommercePromotion.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSECommercePromotion : NSObject

@property (nonatomic, strong) NSString* promotionId;
@property (nonatomic, strong) NSString* creative;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* position;

- (NSDictionary*) dict;

@end

NS_ASSUME_NONNULL_END
