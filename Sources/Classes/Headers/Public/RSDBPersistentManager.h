//
//  DBPersistentManager.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSDBMessage.h"
#import "RSUtils.h"
#import "RSEnums.h"
#import "RSDBEncryption.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSDBPersistentManager : NSObject

- (instancetype)init NS_UNAVAILABLE NS_SWIFT_UNAVAILABLE("Use `RSDBPersistentManager.init(dbEncryption:)` to initialise.");

- (instancetype)initWithDBEncryption:(RSDBEncryption * __nullable)dbEncryption;
-(void) createTables;
-(void) createEventsTableWithVersion:(int) version;
-(void) checkForMigrations;
-(BOOL) checkIfColumnExists:(NSString *) newColumn;
-(void) performMigration:(NSString *) columnName;
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
-(RSDBMessage*)fetchDeviceModeWithProcessedPendingEventsFromDb:(int) limit;
-(int) getDeviceModeWithProcessedPendingEventsRecordCount;
-(void) markDeviceModeTransformationAndProcessedDone:(NSNumber *) messageId;
-(void) markDeviceModeProcessedDone:(NSNumber *) messageId;
@end

NS_ASSUME_NONNULL_END
