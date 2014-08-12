//
//  RDBObject.m
//  REST
//
//  Created by Marcin Raburski on 30.08.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "RDBObject.h"
#import "NSObject+NSValueCodingWithNil.h"
#import "NSMutableDictionary+ObjectKeyPath.h"
#import "RDBObjectJSONProtocol.h"
#import "NSObject+Property.h"
#import "RDBObject+Helpers.h"

@interface RDBObject ()

@end

@implementation RDBObject

+ (RDB*)db {
    return [RDB sharedDB];
}

- (RDB *)db {
    return [RDB sharedDB];
}

- (instancetype)initWithID:(NSString*)uniqueID {
    self = [self init];
    if (self) {
        self._id = uniqueID;
    }
    return self;
}

+ (instancetype)instanceWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        [self pathWithDictionary:dictionary];
    }
    return self;
}

+ (NSArray *)instancesWithArray:(NSArray *)array {
    NSMutableArray *instances = [NSMutableArray new];
    for (NSDictionary *dict in array) {
        [instances addObject:[self instanceWithDictionary: dict]];
    }
    return instances;
}

+ (RDBRequestModel *)requestModelWithOperation:(RDBOperation)operation {
    RDBRequestModel *requestModel = [RDBRequestModel new];
    requestModel.type = self;
    requestModel.operation = operation;
    requestModel.method = [self methodWithRequestModel:requestModel];
    requestModel.path = [self pathWithRequestModel:requestModel];
    requestModel.headers = [self headersWithRequestModel:requestModel];
    requestModel.requestObject = [self requestObjectWithRequestModel:requestModel];
    return requestModel;
}

- (RDBRequestModel *)requestModelWithOperation:(RDBOperation)operation {
    RDBRequestModel *requestModel = [RDBRequestModel new];
    requestModel.type = self.class;
    requestModel.instance = self;
    requestModel.operation = operation;
    requestModel.method = [self methodWithRequestModel:requestModel];
    requestModel.path = [self pathWithRequestModel:requestModel];
    requestModel.headers = [self headersWithRequestModel:requestModel];
    requestModel.requestObject = [self requestObjectWithRequestModel:requestModel];
    return requestModel;
}

+ (NSString *)pathWithRequestModel:(RDBRequestModel *)requestModel {
    if ([self respondsToSelector:@selector(RESTPath)]) {
        return [self RESTPath];
    }
    @throw [NSException exceptionWithName:@"rdb.path.class" reason:@"REST path for class not defined" userInfo:nil];
}

+ (HTTPMethod)methodWithRequestModel:(RDBRequestModel *)requestModel {
    switch (requestModel.operation) {
        case RDBOperationGet:
            return [self db].operationGetMethod;
            break;
        case RDBOperationCreate:
            return [self db].operationCreateMethod;
            break;
        case RDBOperationDelete:
            return [self db].operationDeleteMethod;
            break;
        case RDBOperationUpdate:
            return [self db].operationUpdateMethod;
            break;
            
        default:
            break;
    }
    return HTTPMethodGET;
}

+ (NSDictionary *)headersWithRequestModel:(RDBRequestModel *)requestModel {
    return nil;
}

+ (id)requestObjectWithRequestModel:(RDBRequestModel *)requestModel {
    return nil;
}

- (NSString *)pathWithRequestModel:(RDBRequestModel *)requestModel {
    if ([[self class] respondsToSelector:@selector(RESTPath)]) {
        if (self._id) {
            return [[[self class] RESTPath] stringByAppendingFormat:@"/%@", self._id];
        } else {
            return [[self class] RESTPath];
        }   
    }
    @throw [NSException exceptionWithName:@"rdb.path.instance" reason:@"REST path for class not defined" userInfo:nil];
}

- (HTTPMethod)methodWithRequestModel:(RDBRequestModel *)requestModel {
    return [[self class] methodWithRequestModel:requestModel];
}

- (NSDictionary *)headersWithRequestModel:(RDBRequestModel *)requestModel {
    return [[self class] headersWithRequestModel:requestModel];
}

- (id)requestObjectWithRequestModel:(RDBRequestModel *)requestModel {
    return [self dictionaryRepresentation];
}


+ (NSString*)jsonObjectKeyPath {
    return  nil;
}

- (NSString*)jsonObjectKeyPath {
    return [[self class] jsonObjectKeyPath];
}

+ (NSString*)jsonObjectsKeyPath {
    return nil;
}

- (NSString*)jsonObjectsKeyPath {
    return [[self class] jsonObjectsKeyPath];
}

+ (NSDictionary*)jsonKeyPathToAttributesMapping {
    NSMutableDictionary *mapping = [NSMutableDictionary new];
    NSArray *properties = [self propertyNames];
    for (NSString *property in properties) {
        [mapping setObject:property forKey:property];
    }
    return mapping;
}

- (NSDictionary*)jsonKeyPathToAttributesMapping {
    return [[self class] jsonKeyPathToAttributesMapping];
}

+ (NSDictionary*)jsonKeyPathToClassMapping {
    return nil;
}

- (NSDictionary*)jsonKeyPathToClassMapping {
    return [[self class] jsonKeyPathToClassMapping];
}


- (NSDictionary*)dictionaryRepresentation {
    return [self rdb_dictionaryRepresentation];
}

- (void)pathWithDictionary:(NSDictionary*)dict {
    [self rdb_pathWithDictionary:dict];
}

- (void)requestModelWillStartExecuting:(RDBRequestModel *)requestModel {
    // This can be used by the subclasses
}

- (void)requestModelDidFinishExecuting:(RDBRequestModel *)requestModel {
    // This can be used by the subclasses
}

@end
