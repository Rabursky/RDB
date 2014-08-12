//
//  RDBManagedObject.m
//  KULE Example
//
//  Created by Marcin Raburski on 11.08.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import "RDBManagedObject.h"
#import "RDB.h"
#import "NSObject+Property.h"
#import "RDBObject+Helpers.h"

@implementation RDBManagedObject

+ (instancetype)instanceWithManagedObject:(NSManagedObject *)object {
    return [[self alloc] initWithManagedObject:object];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)object {
    if (self = [super init]) {
        NSDictionary *mapping = [self coreDataKeyPathToAttributesMapping];
        for (NSString *coreDataKeyPath in mapping.allKeys) {
            NSString *property = mapping[coreDataKeyPath];
            [self setValue:[object valueForKeyPath:coreDataKeyPath] forKeyPath:property];
        }
    }
    return self;
}

+ (RDBCoreData *)coreData {
    return [[self db] coreData];
}

- (RDBCoreData *)coreData {
    return [[self class] coreData];
}

+ (NSString *)coreDataClassName {
    return NSStringFromClass(self);
}

+ (NSDictionary*)coreDataKeyPathToAttributesMapping {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[self propertyNames] forKeys:[self propertyNames]];
    [dict setObject:@"_id" forKey:@"id"];
    return dict;
}

- (NSDictionary*)coreDataKeyPathToAttributesMapping {
    return [[self class] coreDataKeyPathToAttributesMapping];
}

+ (RDBOperationMask)coreDataOperationAutomateMask {
    return RDBOperationAll;
}

- (RDBOperationMask)coreDataOperationAutomateMask {
    return [[self class] coreDataOperationAutomateMask];
}

+ (NSManagedObject *)managedObjectWithID:(NSString *)_id inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(id = %@)", _id];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self coreDataClassName]
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    return [array firstObject];
}

- (NSManagedObject *)createManagedObjectInContext:(NSManagedObjectContext *)context {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                            inManagedObjectContext:context];
    NSDictionary *mapping = [self coreDataKeyPathToAttributesMapping];
    for (NSString *coreDataKeyPath in mapping.allKeys) {
        NSString *property = mapping[coreDataKeyPath];
        [object setValue:[self valueForKeyPath:property] forKeyPath:coreDataKeyPath];
    }
    return object;
}

- (NSManagedObject *)managedObjectInContext:(NSManagedObjectContext *)context {
    if (!self._id) {
        @throw [NSException exceptionWithName:@"com.rdb.managedObjectMondel._id" reason:@"ManagedObject should have unique _id" userInfo:nil];
    }
    NSManagedObject *object = [self updatedObjectInContext:context];
    if (!object) {
        object = [self createManagedObjectInContext:context];
    }
    return object;
}

- (NSManagedObject *)updatedObjectInContext:(NSManagedObjectContext *)context {
    NSManagedObject *object = [[self class] managedObjectWithID:self._id inContext:context];
    if (object) {
        NSDictionary *mapping = [self coreDataKeyPathToAttributesMapping];
        for (NSString *coreDataKeyPath in mapping.allKeys) {
            NSString *property = mapping[coreDataKeyPath];
            [object setValue:[self valueForKeyPath:property] forKeyPath:coreDataKeyPath];
        }
    }
    return object;
}

- (void)deleteObjectInContext:(NSManagedObjectContext *)context {
    NSManagedObject *object = [[self class] managedObjectWithID:self._id inContext:context];
    if (object) {
        [context deleteObject:object];
    }
}

- (void)requestModelWillStartExecuting:(RDBRequestModel *)requestModel {
    [super requestModelWillStartExecuting:requestModel];
}

- (void)requestModelDidFinishExecuting:(RDBRequestModel *)requestModel {
    [super requestModelDidFinishExecuting:requestModel];
    RDBOperationMask opertaionMask = [self coreDataOperationAutomateMask];
    if (requestModel.operation | opertaionMask) {
        switch (requestModel.operation) {
            case RDBOperationCreate:
            case RDBOperationUpdate:
            case RDBOperationGet: {
                [self managedObjectInContext:[[self coreData] managedObjectContext]];
            } break;
            case RDBOperationDelete: {
                [self deleteObjectInContext:[[self coreData] managedObjectContext]];
            } break;
            default:
                break;
        }
    }
    
}

@end
