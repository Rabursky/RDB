//
//  RDBObject+Helpers.m
//  KULE Example
//
//  Created by Marcin Raburski on 10.08.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import "RDBObject+Helpers.h"
#import "RDBResponse.h"
#import "NSObject+NSValueCodingWithNil.h"
#import "NSMutableDictionary+ObjectKeyPath.h"
#import "NSObject+Property.h"
#import "RDBObjectJSONProtocol.h"

@implementation RDBObject (Helpers)

+ (void)withID:(NSString*)objectID withCompletionBlock:(RDBCompletionBlock)completionBlock {
    [self withID:objectID withResponseBlock:^(RDBResponse *response) {
        if (completionBlock) {
            completionBlock(response.object, response.metadata, response.error);
        }
    }];
}

+ (void)withID:(NSString*)objectID withResponseBlock:(RDBResponseBlock)responseBlock {
    id<RDBObjectProtocol> object = [[self alloc] initWithID:objectID];
    RDBRequestModel *requestModel = [object requestModelWithOperation:RDBOperationGet];
    [[self db] executeRequestModel:requestModel withResponseBlock:^(RDBResponse *response) {
        if (responseBlock) {
            responseBlock(response);
        }
    }];
}

+ (void)allWithCompletionBlock:(RDBCompletionBlock)completionBlock {
    [self allWithResponseBlock:^(RDBResponse *response) {
        if (completionBlock) {
            completionBlock(response.object, response.metadata, response.error);
        }
    }];
}

+ (void)allWithResponseBlock:(RDBResponseBlock)responseBlock {
    RDBRequestModel *requestModel = [(id<RDBObjectProtocol>)self requestModelWithOperation:RDBOperationGet];
    [[self db] executeRequestModel:requestModel withResponseBlock:^(RDBResponse *response) {
        if (responseBlock) {
            responseBlock(response);
        }
    }];
}

// Updates an object or creates new when ones has no _id
- (void)save {
    [self saveWithCompletionBlock:nil];
}

- (void)saveWithCompletionBlock:(RDBCompletionBlock)completionBlock {
    [self saveWithResponseBlock:^(RDBResponse *response) {
        if (completionBlock) {
            completionBlock(response.object, response.metadata, response.error);
        }
    }];
}

- (void)saveWithResponseBlock:(RDBResponseBlock)responseBlock {
    RDBRequestModel *requestModel;
    if ([(id<RDBObjectProtocol>)self _id]) {
        requestModel = [(id<RDBObjectProtocol>)self requestModelWithOperation:RDBOperationUpdate];
    } else {
        requestModel = [(id<RDBObjectProtocol>)self requestModelWithOperation:RDBOperationCreate];
    }
    [[self db] executeRequestModel:requestModel withResponseBlock:^(RDBResponse *response) {
        if (responseBlock) {
            responseBlock(response);
        }
    }];
}

// Removes object from RDB
- (void)remove {
    [self removeWithCompletionBlock:nil];
}

- (void)removeWithCompletionBlock:(RDBCompletionBlock)completionBlock {
    [self removeWithResponseBlock:^(RDBResponse *response) {
        if (completionBlock) {
            completionBlock(response.object, response.metadata, response.error);
        }
    }];
}

- (void)removeWithResponseBlock:(RDBResponseBlock)responseBlock {
    RDBRequestModel *requestModel = [(id<RDBObjectProtocol>)self requestModelWithOperation:RDBOperationDelete];
    [[self db] executeRequestModel:requestModel withResponseBlock:^(RDBResponse *response) {
        if (responseBlock) {
            responseBlock(response);
        }
    }];
}

#pragma mark - OTHER helpers


- (NSDictionary*)rdb_dictionaryRepresentation {
    NSDictionary *attributes = [(id<RDBObjectProtocol>)self jsonKeyPathToAttributesMapping];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *keypath in attributes.allKeys) {
        NSString *property = [attributes objectForKey:keypath];
        id value = [self valueForKeyPathWithNil:property];
        if (value) {
            id object = [self rdb_replaceObjectsInObject:value withReplaceBlock:^id(id innerObject) {
                return [self rdb_JSONValueFromObject:innerObject];
            }];
            if (object) {
                [dict setObject:object forKeyPath:keypath];
            }
        }
    }
    return dict;
}

- (void)rdb_pathWithDictionary:(NSDictionary*)dict {
    NSDictionary *attributes = [(id<RDBObjectProtocol>)self jsonKeyPathToAttributesMapping];
    NSDictionary *classes = [(id<RDBObjectProtocol>)self jsonKeyPathToClassMapping];
    if ([dict.allKeys containsObject:@"_id"]) {
        [(id<RDBObjectProtocol>)self set_id:dict[@"_id"]];
    }
    for (NSString *keypath in attributes.allKeys) {
        id value = [dict valueForKeyPathWithNil:keypath];
        NSString *property = [attributes objectForKey:keypath];
        Class class = Nil;
        if ([classes.allKeys containsObject:keypath]) {
            class = [classes objectForKey:keypath];
        } else {
            class = NSClassFromString([self classNameOfPropertyWithName:property]);
        }
        if (value && property) {
            id object = [self rdb_replaceObjectsInObject:value withReplaceBlock:^id(id innerObject) {
                id singleObject = [self rdb_objectFromJSONValue:innerObject andObjectClass:class];
                if ([singleObject respondsToSelector:@selector(setParent:)]) {
                    [singleObject setParent:self];
                }
                return singleObject;
            }];
            if (object) {
                [self setValue:object forKeyPath:property];
            }
        }
    }
}

// replaces objects in either NSArray, NSDictionary or stand-alone
- (id)rdb_replaceObjectsInObject:(id)value withReplaceBlock:(RDBReplaceBlock)replaceBlock {
    id object = nil;
    if ([value isKindOfClass:[NSArray class]]) {
        object = [[NSMutableArray alloc] init];
        for (id obj in value) {
            [object addObject:replaceBlock(obj)];
        }
    } else {
        object = replaceBlock(value);
    }
    return object;
}

- (id)rdb_objectFromJSONValue:(id)value andObjectClass:(Class)class {
    id object = nil;
    if ([class conformsToProtocol:@protocol(RDBObjectProtocol)]) {
        object = [class instanceWithDictionary:value];
    } else if ([class respondsToSelector:@selector(objectWithJSONValue:)]) { // conforms to protocol RDBObjectJSONProtocol
        object = [class objectWithJSONValue:value];
    } else {
        object = value;
    }
    return object;
}

- (id)rdb_JSONValueFromObject:(id)value {
    id object = value;
    if ([value conformsToProtocol:@protocol(RDBObjectProtocol)]) {
        object = [object dictionaryRepresentation];
    } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
        object = [self rdb_replaceObjectsInObject:value withReplaceBlock:^id(id innerObject) {
            return [self rdb_JSONValueFromObject:innerObject];
        }];
    } else if ([value respondsToSelector:@selector(JSONValue)]) // conforms to protocol RDBObjectJSONProtocol
    {
        object = [value JSONValue];
    }
    return object;
}


@end
