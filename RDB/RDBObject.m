//
//  RDBObject.m
//  REST
//
//  Created by Marcin Raburski on 30.08.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "RDBObject.h"

@implementation RDBObject

+ (RDB*)db {
    return [RDB sharedDB];
}

+ (void)withID:(NSString*)objectID withCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[self db] objectOfClass:self withID:objectID withCompletionBlock:completionBlock];
}

+ (void)allWithCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[self db] objectsOfClass:self withCompletionBlock:completionBlock];
}

- (instancetype)initWithID:(NSString*)uniqueID {
    self = [super init];
    if (self) {
        self._id = uniqueID;
    }
    return self;
}

- (void)updateID:(NSString*)uniqueID {
    self._id = uniqueID;
}

// Updates an object or creates new when ones has no _id
- (void)update {
    [[[self class] db] updateObject:self];
}

- (void)updateWithCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[[self class] db] updateObject:self withCompletionBlock:completionBlock];
}

// Removes object from RDB
- (void)remove {
    [[[self class] db] removeObject:self];
}

- (void)removeWithCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[[self class] db] removeObject:self withCompletionBlock:completionBlock];
}

@end
