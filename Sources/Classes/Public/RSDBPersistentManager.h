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

typedef enum {
    NOT_PROCESSED =0,
    DEVICE_MODE_PROCESSING_DONE =1,
    CLOUD_MODE_PROCESSING_DONE =2,
    COMPLETE_PROCESSING_DONE =3
} EVENT_PROCESSING_STATUS;

typedef enum {
    CLOUDMODE =2,
    DEVICEMODE =1,
    ALL = 3
} MODES;

NS_ASSUME_NONNULL_BEGIN

@interface RSDBPersistentManager : NSObject {
    sqlite3 *_database;
}

-(void) createDB;
-(void) createTables;
-(void) createEventsTableWithVersion:(int) version;
-(void) checkForMigrations;
-(BOOL) checkIfStatusColumnExists;
-(void) performMigration;
-(NSNumber*) saveEvent: (NSString*) message;
- (void) clearOldEventsWithThreshold:(int)threshold;
-(void) clearEventsFromDB: (NSMutableArray*) messageIds;
-(RSDBMessage *)fetchEventsFromDB:(int)count ForMode:(MODES) mode;
-(RSDBMessage*) fetchAllEventsFromDBForMode:(MODES) mode;
-(void) updateEventWithId:(NSNumber *) messageId withStatus:(EVENT_PROCESSING_STATUS) status;
-(void) updateEventsWithIds:(NSArray*) messageIds withStatus:(EVENT_PROCESSING_STATUS) status;
-(void) clearProcessedEventsFromDB;
- (int) getDBRecordCountForMode:(MODES) mode;
-(void) flushEventsFromDB;

@end

NS_ASSUME_NONNULL_END
