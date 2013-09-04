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

// If you want to use another object (or subclass) instead of RDB
// change object being returned by this method in subclass
+ (RDB*)db;

// Convenient getters
+ (void)withID:(NSString*)objectID withCompletionBlock:(RDBCompletionBlock)completionBlock;
+ (void)allWithCompletionBlock:(RDBCompletionBlock)completionBlock;

- (instancetype)initWithID:(NSString*)uniqueID;

// Updates an object or creates new when ones has no _id
- (void)update;
- (void)updateWithCompletionBlock:(RDBCompletionBlock)completionBlock;

// Removes object from RDB
- (void)remove;
- (void)removeWithCompletionBlock:(RDBCompletionBlock)completionBlock;

@end
