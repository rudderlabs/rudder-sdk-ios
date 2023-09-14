//
//  RSDBEncryption.h
//  Rudder
//
//  Created by Pallab Maiti on 09/08/23.
//

#import <Foundation/Foundation.h>
#import "RSDatabaseProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSDBEncryption : NSObject

- (instancetype)init NS_UNAVAILABLE NS_SWIFT_UNAVAILABLE("Use `RSDBEncryption.init(key:enable:databaseProvider:)` to initialise.");

- (instancetype)initWithKey:(NSString *)key enable:(BOOL)enable databaseProvider:(id <RSDatabaseProvider> _Nonnull)databaseProvider;

@property (nonatomic, nonnull) NSString *key;
@property (nonatomic) BOOL enable;
@property (nonatomic) id <RSDatabaseProvider> _Nonnull databaseProvider;

@end

NS_ASSUME_NONNULL_END
