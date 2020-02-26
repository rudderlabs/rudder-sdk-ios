//
//  CartSharedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "CartSharedEvent.h"
#import "ECommerceParamNames.h"

@implementation CartSharedEvent

- (instancetype)withCart:(ECommerceCart *)cart {
    _cart = cart;
    return self;
}

- (instancetype)withCartBuilder:(ECommerceCartBuilder *)builder {
    _cart = [builder build];
    return self;
}

- (instancetype)withSocialChannel:(NSString *)socialChannel {
    _socialChannel = socialChannel;
    return self;
}

- (instancetype)withShareMessage:(NSString *)shareMessage {
    _shareMessage = shareMessage;
    return self;
}

- (instancetype)withRecipient:(NSString *)recipient {
    _recipient = recipient;
    return self;
}

- (nonnull NSString *)event {
    return ECommCartShared;
}

- (nonnull NSDictionary *)properties {
    NSMutableDictionary *property = [[NSMutableDictionary alloc] init];
    
    [property setValue:_cart.cartId forKey:KeyCartId];
    NSArray *products = _cart.products;
    NSMutableArray *productArr = [[NSMutableArray alloc] init];
    if (products != nil) {
        for (ECommerceProduct *product in products) {
            [productArr addObject:@{
                KeyProductId: product.productId
            }];
        }
    }
    [property setValue:productArr forKey:KeyProducts];
    
    if (_socialChannel != nil) {
        [property setValue:_socialChannel forKey:KeyShareVia];
    }
    if (_shareMessage != nil) {
        [property setValue:_shareMessage forKey:KeyShareMessage];
    }
    if (_recipient != nil) {
        [property setValue:_recipient forKey:KeyRecipient];
    }
    
    return [property copy];
}

@end
