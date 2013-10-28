//
//  RDBObject.m
//  REST
//
//  Created by Marcin Raburski on 30.08.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "RDBObject.h"
#import "RDBObjectRefFactory.h"

@implementation RDBObject

+ (RDB*)db {
    return [RDB sharedDB];
}

+ (Class)classRef {
    // Know it aint beutiful.
    return [RDBObjectRefFactory objectFactoryWithClass:[self class]];
}

+ (void)withID:(NSString*)objectID withCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[self db] objectOfClass:self withID:objectID withCompletionBlock:completionBlock];
}

+ (void)allWithCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[self db] objectsOfClass:self withCompletionBlock:completionBlock];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ref = NO;
    }
    return self;
}

- (instancetype)initWithID:(NSString*)uniqueID {
    self = [self init];
    if (self) {
        self._id = uniqueID;
    }
    return self;
}

- (void)updateID:(NSString*)uniqueID {
    self._id = uniqueID;
}

// Updates an object or creates new when ones has no _id
- (void)save {
    [[[self class] db] saveObject:self];
}

- (void)saveWithCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[[self class] db] saveObject:self withCompletionBlock:completionBlock];
}

// Removes object from RDB
- (void)remove {
    [[[self class] db] removeObject:self];
}

- (void)removeWithCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[[self class] db] removeObject:self withCompletionBlock:completionBlock];
}

- (void)getWithCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[[self class] db] updateObject:self withCompletionBlock:completionBlock];
}

@end
