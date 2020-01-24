//
//  ProductListFilteredEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceProduct.h"
#import "ECommerceSort.h"
#import "ECommerceFilter.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductListFilteredEvent : NSObject

@property (nonatomic, strong) NSString *listId;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, strong) NSMutableArray *sorts;
@property (nonatomic, strong) NSMutableArray *filters;

- (instancetype) withListId: (NSString*) listId;
- (instancetype) withCategory: (NSString*) category;
- (instancetype) withProducts: (NSArray<ECommerceProduct*>*) products;
- (instancetype) withProduct: (ECommerceProduct*) product;
- (instancetype) withFilters: (NSArray<ECommerceFilter*>*) filters;
- (instancetype) withFilter: (ECommerceFilter*) filter;
- (instancetype) withSorts: (NSArray<ECommerceSort*>*) sorts;
- (instancetype) withSort: (ECommerceSort*) sort;


- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
