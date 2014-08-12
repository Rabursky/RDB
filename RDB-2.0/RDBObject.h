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
#import "RDBRequestModel.h"

@interface RDBObject : NSObject <RDBObjectProtocol>

// Object id should be stored in this property
// By default we are looking for it in dictionary at key @"_id"
// You can customize it by adding _id to jsonKeyPathToAttributesMapping
@property (nonatomic) NSString *_id;

// if model is embeded in other model, ot may have a parent
@property (nonatomic, weak) id parent;

- (instancetype)initWithID:(NSString*)uniqueID;
+ (instancetype)instanceWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)instancesWithArray:(NSArray *)array;

// If you want to use another object (or subclass) instead of RDB
// change object being returned by this method in subclass
+ (RDB *)db;
- (RDB *)db;

+ (NSDictionary*)jsonKeyPathToAttributesMapping;
- (NSDictionary*)jsonKeyPathToAttributesMapping;

+ (RDBRequestModel *)requestModelWithOperation:(RDBOperation)operation;
- (RDBRequestModel *)requestModelWithOperation:(RDBOperation)operation;

// when making class queries
+ (NSString *)pathWithRequestModel:(RDBRequestModel *)requestModel;
+ (HTTPMethod)methodWithRequestModel:(RDBRequestModel *)requestModel;
+ (NSDictionary *)headersWithRequestModel:(RDBRequestModel *)requestModel;
+ (id)requestObjectWithRequestModel:(RDBRequestModel *)requestModel;

// when making instance queries
- (NSString *)pathWithRequestModel:(RDBRequestModel *)requestModel;
- (HTTPMethod)methodWithRequestModel:(RDBRequestModel *)requestModel;
- (NSDictionary *)headersWithRequestModel:(RDBRequestModel *)requestModel;
- (id)requestObjectWithRequestModel:(RDBRequestModel *)requestModel;

// converting to json
- (NSDictionary *)dictionaryRepresentation;
- (void)pathWithDictionary:(NSDictionary*)dict;


// kind of delegate methods
- (void)requestModelWillStartExecuting:(RDBRequestModel *)requestModel;
- (void)requestModelDidFinishExecuting:(RDBRequestModel *)requestModel;

@end
