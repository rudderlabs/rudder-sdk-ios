//
//  ProductListFilteredEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceProduct.h"
#import "RSECommerceSort.h"
#import "RSECommerceFilter.h"
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductListFilteredEvent : NSObject

@property (nonatomic, strong) NSString *listId;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, strong) NSMutableArray *sorts;
@property (nonatomic, strong) NSMutableArray *filters;

- (instancetype) withListId: (NSString*) listId;
- (instancetype) withCategory: (NSString*) category;
- (instancetype) withProducts: (NSArray<RSECommerceProduct*>*) products;
- (instancetype) withProduct: (RSECommerceProduct*) product;
- (instancetype) withFilters: (NSArray<RSECommerceFilter*>*) filters;
- (instancetype) withFilter: (RSECommerceFilter*) filter;
- (instancetype) withSorts: (NSArray<RSECommerceSort*>*) sorts;
- (instancetype) withSort: (RSECommerceSort*) sort;


- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
