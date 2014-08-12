//
//  RDBManagedObject.h
//  KULE Example
//
//  Created by Marcin Raburski on 11.08.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RDB.h"
#import "RDBObject.h"

@interface RDBManagedObject : RDBObject

+ (instancetype)instanceWithManagedObject:(NSManagedObject *)object;
- (instancetype)initWithManagedObject:(NSManagedObject *)object;

// used for auto operations
+ (RDBCoreData *)coreData;
- (RDBCoreData *)coreData;

+ (NSString *)coreDataClassName;
+ (NSDictionary*)coreDataKeyPathToAttributesMapping;
- (NSDictionary*)coreDataKeyPathToAttributesMapping;

// which operations should be automatically applied to the coredata (based on _id)
+ (RDBOperationMask)coreDataOperationAutomateMask;
- (RDBOperationMask)coreDataOperationAutomateMask;

+ (NSManagedObject *)managedObjectWithID:(NSString *)_id inContext:(NSManagedObjectContext *)context;

// either creates one or returns already stored and updated
- (NSManagedObject *)managedObjectInContext:(NSManagedObjectContext *)context;

// withID + updates fields
- (NSManagedObject *)updatedObjectInContext:(NSManagedObjectContext *)context;

- (void)deleteObjectInContext:(NSManagedObjectContext *)context;

@end
