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
    NOTPROCESSED =0,
    DEVICEMODEPROCESSINGDONE =1,
    CLOUDMODEPROCESSINGDONE =2,
    COMPLETEPROCESSINGDONE =3
} EVENTPROCESSINGSTATUS;

typedef enum {
    CLOUDMODE =2,
    DEVICEMODE =1
} MODES;

NS_ASSUME_NONNULL_BEGIN

@interface RSDBPersistentManager : NSObject {
    sqlite3 *_database;
}

-(void) createDB;
-(void) createTables;
-(void) createEventsTableWithVersion:(int) version;
-(void) createEventsToDestinationIdMappingTable;
-(void) checkForMigrations;
-(BOOL) checkIfStatusColumnExists;
-(void) performMigration;
-(NSNumber*) saveEvent: (NSString*) message;
-(void) clearEventsFromDB: (NSMutableArray*) messageIds;
-(RSDBMessage *)fetchEventsFromDB:(int)count ForMode:(MODES) mode;
-(RSDBMessage*) fetchAllEventsFromDBForMode:(MODES) mode;
-(void) updateEventsWithIds:(NSMutableArray*) messageIds withStatus:(EVENTPROCESSINGSTATUS) status;
-(void) clearProcessedEventsFromDB;
-(NSArray<NSString*>*) getEventIdsWithDestinationMapping:(NSArray*) eventIds;
- (void) saveEvent:(NSNumber*) rowId toDestinationId:(NSString*) destinationId;
- (void) deleteEvents:(NSArray*) eventIds withDestinationId:(NSString*) destinationId;
-(NSDictionary<NSString*, NSArray<NSString*>*>*) getDestinationMappingofEvents:(NSArray<NSString*>*) eventIds;
- (int) getDBRecordCountForMode:(MODES) mode;
-(void) flushEventsFromDB;

@end

NS_ASSUME_NONNULL_END
