//
//  RudderTraits.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderTraits.h"
#import "RudderElementCache.h"
#import "Utils.h"

@implementation RudderTraits

- (instancetype)init
{
    self = [super init];
    if (self) {
        RudderContext *context = [RudderElementCache getContext];
        if (context.traits != nil) {
            self = context.traits;
        } else {
            self.anonymousId = context.device.identifier;
        }
    }
    return self;
}

- (instancetype)init: (NSString*) anonymouysId
{
    self = [super init];
    if (self) {
        self.anonymousId = anonymouysId;
    }
    return self;
}


- (NSString *)getId {
    return self.userId;
}

- (NSMutableDictionary<NSString *,NSObject *> *)getExtras {
    return self._extras;
}

- (void)putAddress:(NSMutableDictionary<NSString *,NSObject *> *)address {
    self.adderess = address;
}

- (void)putAge:(NSString *)age {
    self.age = age;
}

- (void)putBirthdayString:(NSString *)birthday {
    self.birthday = birthday;
}

- (void) putBirthday:(NSDate *)birthday {
    self.birthday = [Utils getDateString: birthday];
}

- (void)putCompany:(NSMutableDictionary<NSString *,NSObject *> *)company {
    self.company = company;
}

- (void)putCreatedAt:(NSString *)createdAt {
    self.createdAt = createdAt;
}

- (void)putDescription:(NSString *)traitsDescription {
    self.traitsDescription = traitsDescription;
}

- (void)putEmail:(NSString *)email {
    self.email = email;
}

- (void)putFirstName:(NSString *)firstName {
    self.firstName = firstName;
}

- (void)putGender:(NSString *)gender {
    self.gender = gender;
}

- (void)putId:(NSString *)userId {
    self.userId = userId;
}

- (void)putLastName:(NSString *)lastName {
    self.lastName = lastName;
}

- (void)putName:(NSString *)name {
    self.name = name;
}

- (void)putPhone:(NSString *)phone {
    self.phone = phone;
}

- (void)putTitle:(NSString *)title {
    self.title = title;
}

- (void)putUserName:(NSString *)userName {
    self.userName = userName;
}

- (void)put:(NSString *)key value:(NSObject *)value {
    if (value != nil) {
        [self._extras setValue:value forKey:key];
    }
}
- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary<NSString*, NSObject*> *tempDict = [[NSMutableDictionary alloc] init];
    
    [tempDict setValue:_anonymousId forKey:@"anonymousId"];
    [tempDict setValue:_adderess forKey:@"address"];
    [tempDict setValue:_age forKey:@"age"];
    [tempDict setValue:_birthday forKey:@"birthday"];
    [tempDict setValue:_company forKey:@"company"];
    [tempDict setValue:_createdAt forKey:@"createdAt"];
    [tempDict setValue:_traitsDescription forKey:@"description"];
    [tempDict setValue:_email forKey:@"email"];
    [tempDict setValue:_firstName forKey:@"firstname"];
    [tempDict setValue:_gender forKey:@"gender"];
    [tempDict setValue:_userId forKey:@"id"];
    [tempDict setValue:_lastName forKey:@"lastname"];
    [tempDict setValue:_name forKey:@"name"];
    [tempDict setValue:_phone forKey:@"phone"];
    [tempDict setValue:_title forKey:@"title"];
    [tempDict setValue:_userName forKey:@"userName"];
    [tempDict setValuesForKeysWithDictionary:__extras];
    
    return [tempDict copy];
}

@end
