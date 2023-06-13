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
#import "RSEnums.h"


NS_ASSUME_NONNULL_BEGIN

@interface RSDBPersistentManager : NSObject {
    sqlite3 *_database;
    NSLock* lock;
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
-(void) markUnProcessedDeviceModeEventsStatusesAsDeviceModeProcessingDone;

@end

NS_ASSUME_NONNULL_END
