//
//  ECommerceWishList.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceWishList : NSObject

@property (nonatomic, strong) NSString* wishListId;
@property (nonatomic, strong) NSString* wishListName;

- (NSDictionary*) dict;

@end

NS_ASSUME_NONNULL_END
