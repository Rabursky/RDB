//
//  RDBObject+Helpers.h
//  KULE Example
//
//  Created by Marcin Raburski on 10.08.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import "RDBObject.h"

@interface RDBObject (Helpers)

//+ (void)withCompletionBlock:(RDBCompletionBlock)completionBlock;
+ (void)withID:(NSString*)objectID withCompletionBlock:(RDBCompletionBlock)completionBlock;
+ (void)withID:(NSString*)objectID withResponseBlock:(RDBResponseBlock)responseBlock;
+ (void)allWithCompletionBlock:(RDBCompletionBlock)completionBlock;
+ (void)allWithResponseBlock:(RDBResponseBlock)responseBlock;

// Updates an object or creates new when ones has no _id
- (void)save;
- (void)saveWithCompletionBlock:(RDBCompletionBlock)completionBlock;
- (void)saveWithResponseBlock:(RDBResponseBlock)responseBlock;

// Removes object from RDB
- (void)remove;
- (void)removeWithCompletionBlock:(RDBCompletionBlock)completionBlock;
- (void)removeWithResponseBlock:(RDBResponseBlock)responseBlock;

- (NSDictionary*)rdb_dictionaryRepresentation;
- (void)rdb_pathWithDictionary:(NSDictionary*)dict;

@end
