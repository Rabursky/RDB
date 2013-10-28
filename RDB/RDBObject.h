//
//  RDBObject.h
//  REST
//
//  Created by Marcin Raburski on 30.08.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDB.h"
#import "RDBObjectProtocol.h"

@interface RDBObject : NSObject <RDBObjectProtocol>

// Object id should be stored in this property
// By default we are looking for it in dictionary at key @"_id"
// You can customize it by adding _id to jsonKeyPathToAttributesMapping
@property (nonatomic) NSString *_id;
// If json value for objects wasnt just an ID
// If object is Ref, you can download its content using getWithCompletionBlock
@property (nonatomic, getter = isRef) BOOL ref;

// If you want to use another object (or subclass) instead of RDB
// change object being returned by this method in subclass
+ (RDB*)db;

// use classRef instead of [RDBObject class] in defining jsonKeyPathToClassMapping
// if you know that there will be no object but string representing objects _id
// Object created with this class will be RDB object with .isRef = YES
// and ability to use - (void)getWithCompletionBlock method
+ (Class)classRef;

// Convenient getters
+ (void)withID:(NSString*)objectID withCompletionBlock:(RDBCompletionBlock)completionBlock;
+ (void)allWithCompletionBlock:(RDBCompletionBlock)completionBlock;

- (instancetype)initWithID:(NSString*)uniqueID;

// Updates an object or creates new when ones has no _id
- (void)save;
- (void)saveWithCompletionBlock:(RDBCompletionBlock)completionBlock;

// Removes object from RDB
- (void)remove;
- (void)removeWithCompletionBlock:(RDBCompletionBlock)completionBlock;

- (void)getWithCompletionBlock:(RDBCompletionBlock)completionBlock;
//- (void)updateAllWithCompletionBlock:(RDBCompletionBlock)completionBlock;

@end
