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

- (instancetype)init {
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

- (instancetype) initWithDict: (NSDictionary*) dict {
    self = [super init];
    if(self) {
        // if anonymousId is not present in supplied dict
        NSString *anonymousId = [dict objectForKey:@"anonymousId"];
        if (anonymousId == nil) {
            RudderContext *context = [RudderElementCache getContext];
            _anonymousId = context.device.identifier;
        }
        __extras = [[NSMutableDictionary alloc] init];
        [__extras setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (instancetype)init: (NSString*) anonymouysId {
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
    
    if (_anonymousId != nil) {
        [tempDict setValue:_anonymousId forKey:@"anonymousId"];
    }
    if (_adderess != nil) {
        [tempDict setValue:_adderess forKey:@"address"];
    }
    if (_age != nil) {
        [tempDict setValue:_age forKey:@"age"];
    }
    if (_birthday != nil) {
        [tempDict setValue:_birthday forKey:@"birthday"];
    }
    if (_company != nil) {
        [tempDict setValue:_company forKey:@"company"];
    }
    if (_createdAt != nil) {
        [tempDict setValue:_createdAt forKey:@"createdAt"];
    }
    if (_traitsDescription != nil) {
        [tempDict setValue:_traitsDescription forKey:@"description"];
    }
    if (_email != nil) {
        [tempDict setValue:_email forKey:@"email"];
    }
    if (_firstName != nil) {
        [tempDict setValue:_firstName forKey:@"firstname"];
    }
    if (_gender != nil) {
        [tempDict setValue:_gender forKey:@"gender"];
    }
    if (_userId != nil) {
        [tempDict setValue:_userId forKey:@"id"];
    }
    if (_lastName != nil) {
        [tempDict setValue:_lastName forKey:@"lastname"];
    }
    if (_name != nil) {
        [tempDict setValue:_name forKey:@"name"];
    }
    if (_phone != nil) {
        [tempDict setValue:_phone forKey:@"phone"];
    }
    if (_title != nil) {
        [tempDict setValue:_title forKey:@"title"];
    }
    if (_userName != nil) {
        [tempDict setValue:_userName forKey:@"userName"];
    }
    if (__extras != nil) {
        [tempDict setValuesForKeysWithDictionary:__extras];
    }
    
    return [tempDict copy];
}

@end
