//
//  RudderTraits.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderTraits : NSObject

@property (nonatomic, readwrite) NSString *anonymousId;
@property (nonatomic) NSMutableDictionary<NSString*, NSObject*> *adderess;
@property (nonatomic) NSString *age;
@property (nonatomic) NSString *birthday;
@property (nonatomic) NSMutableDictionary<NSString*, NSObject*> *company;
@property (nonatomic) NSString *createdAt;
@property (nonatomic) NSString *traitsDescription;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *gender;
@property (nonatomic, assign) NSString * userId;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSMutableDictionary<NSString*, NSObject*> *_extras;

- (NSString*) getId;
- (NSMutableDictionary<NSString*, NSObject*> *) getExtras;
- (void) putAddress: (NSMutableDictionary<NSString*, NSObject*> *) address;
- (void) putAge: (NSString*) age;
- (void) putBirthdayString: (NSString*) birthday;
- (void) putBirthday: (NSDate*) birthday;
- (void) putCompany: (NSMutableDictionary<NSString*, NSObject*> *) company;
- (void) putCreatedAt: (NSString*) createdAt;
- (void) putDescription: (NSString*) traitsDescription;
- (void) putEmail: (NSString*) email;
- (void) putFirstName: (NSString*) firstName;
- (void) putGender: (NSString*) gender;
- (void) putId: (NSString*) userId;
- (void) putLastName: (NSString*) lastName;
- (void) putName: (NSString*) name;
- (void) putPhone: (NSString*) phone;
- (void) putTitle: (NSString*) title;
- (void) putUserName: (NSString*) userName;
- (void) put: (NSString*) key value: (NSObject*) value;

- (NSDictionary<NSString*, NSObject*>*) dict;
- (instancetype)initWithDict:(NSDictionary*) dict;

@end

@interface Address : NSObject

@end

@interface Company : NSObject

@end

NS_ASSUME_NONNULL_END
