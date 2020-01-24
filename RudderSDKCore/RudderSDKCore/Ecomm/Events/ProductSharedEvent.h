//
//  ProductSharedEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceEvents.h"
#import "ECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductSharedEvent : NSObject

@property (nonatomic, strong) ECommerceProduct *product;
@property (nonatomic, strong) NSString *socialChannel;
@property (nonatomic, strong) NSString *shareMessage;
@property (nonatomic, strong) NSString *recipient;

- (instancetype) withProduct: (ECommerceProduct*) product;
- (instancetype) withSocialChannel: (NSString*) socialChannel;
- (instancetype) withShareMessage: (NSString*) shareMessage;
- (instancetype) withRecipient: (NSString*) recipient;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
