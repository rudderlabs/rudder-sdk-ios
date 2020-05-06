//
//  ProductSharedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ProductSharedEvent.h"
#import "ECommerceParamNames.h"

@implementation ProductSharedEvent

- (instancetype)withProduct:(ECommerceProduct *)product {
    _product = product;
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
    return ECommProductShared;
}

- (nonnull NSDictionary *)properties {
    NSMutableDictionary *property = [[NSMutableDictionary alloc] init];
    
    if (_product != nil) {
        [property setDictionary:[_product dict]];
    }
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
