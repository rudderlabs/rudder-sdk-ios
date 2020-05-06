//
//  ProductListViewedEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceProduct.h"
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductListViewedEvent : NSObject

@property (nonatomic, strong) NSString *listId;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSMutableArray *products;

- (instancetype) withListId: (NSString*) listId;
- (instancetype) withCategory: (NSString*) category;
- (instancetype) withProducts: (NSArray<RSECommerceProduct*>*) products;
- (instancetype) withProduct: (RSECommerceProduct*) product;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
