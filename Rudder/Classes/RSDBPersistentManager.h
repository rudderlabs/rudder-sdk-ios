//
//  DBPersistentManager.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "RSDBMessage.h"
#import "RSUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSDBPersistentManager : NSObject {
    sqlite3 *_database;
}

-(void) createDB;
-(void) createSchema;
-(void) saveEvent: (NSString*) message;
-(void) clearEventFromDB: (int) messageId;
-(void) clearEventsFromDB: (NSMutableArray*) messageIds;
-(RSDBMessage*) fetchEventsFromDB:(int) count;
-(int) getDBRecordCount;
-(void) flushEventsFromDB;

@end

NS_ASSUME_NONNULL_END
