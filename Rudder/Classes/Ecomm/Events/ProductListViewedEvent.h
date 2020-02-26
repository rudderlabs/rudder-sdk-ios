//
//  ProductListViewedEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceProduct.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductListViewedEvent : NSObject

@property (nonatomic, strong) NSString *listId;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSMutableArray *products;

- (instancetype) withListId: (NSString*) listId;
- (instancetype) withCategory: (NSString*) category;
- (instancetype) withProducts: (NSArray<ECommerceProduct*>*) products;
- (instancetype) withProduct: (ECommerceProduct*) product;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
