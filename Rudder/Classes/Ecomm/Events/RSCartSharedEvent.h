//
//  CartSharedEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceEvents.h"
#import "RSECommerceCart.h"
#import "RSECommerceCartBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface CartSharedEvent : NSObject

@property (nonatomic, strong) RSECommerceCart *cart;
@property (nonatomic, strong) NSString *socialChannel;
@property (nonatomic, strong) NSString *shareMessage;
@property (nonatomic, strong) NSString *recipient;

- (instancetype) withCart: (RSECommerceCart*) cart;
- (instancetype) withCartBuilder: (RSECommerceCartBuilder*) builder;
- (instancetype) withSocialChannel: (NSString*) socialChannel;
- (instancetype) withShareMessage: (NSString*) shareMessage;
- (instancetype) withRecipient: (NSString*) recipient;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
