//
//  DBPersistentManager.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "RudderDBMessage.h"
#import "Utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBPersistentManager : NSObject {
    sqlite3 *_database;
}

-(void) createDB;
-(void) createSchema;
-(void) saveEvent: (NSString*) message;
-(void) clearEventFromDB: (int) messageId;
-(void) clearEventsFromDB: (NSArray*) messageIds;
-(RudderDBMessage*) fetchEventsFromDB:(int) count;
-(int) getDBRecordCount;
-(void) deleteAllEvents;

@end

NS_ASSUME_NONNULL_END
