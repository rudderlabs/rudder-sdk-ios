//
//  RSDBEncryption.h
//  Rudder
//
//  Created by Pallab Maiti on 09/08/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSDBEncryption : NSObject

- (instancetype)init NS_UNAVAILABLE NS_SWIFT_UNAVAILABLE("Use `RSDBEncryption.init(key:enable:)` to initialise.");

- (instancetype)initWithKey:(NSString *)key enable:(BOOL)enable;

@property (nonatomic, nonnull) NSString *key;
@property (nonatomic) BOOL enable;

@end

NS_ASSUME_NONNULL_END
