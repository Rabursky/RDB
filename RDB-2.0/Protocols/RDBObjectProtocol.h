//
//  RDBObjectProtocol.h
//  REST
//
//  Created by Marcin Raburski on 04.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDB.h"

@class RDBRequestModel;

@protocol RDBObjectProtocol <NSObject>

@property (nonatomic) NSString *_id;

- (instancetype)initWithID:(NSString*)uniqueID;
+ (instancetype)instanceWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)instancesWithArray:(NSArray *)array;

// If you want to use another object (or subclass) instead of RDB
// change object being returned by this method in subclass
+ (RDB *)db;
- (RDB *)db;

// Legacy methods, might be used aswell
@optional
+ (NSString*)RESTPath;
+ (NSString*)jsonObjectKeyPath;
- (NSString*)jsonObjectKeyPath;
+ (NSString*)jsonObjectsKeyPath;
- (NSString*)jsonObjectsKeyPath;
+ (NSDictionary*)jsonKeyPathToAttributesMapping;
- (NSDictionary*)jsonKeyPathToAttributesMapping;

// if some objects are in the array
// we have to define what kind of objects should it be
+ (NSDictionary*)jsonKeyPathToClassMapping;
- (NSDictionary*)jsonKeyPathToClassMapping;

// creating class and instance request models
+ (RDBRequestModel *)requestModelWithOperation:(RDBOperation)operation;
- (RDBRequestModel *)requestModelWithOperation:(RDBOperation)operation;

// when making class queries
+ (NSString *)pathWithRequestModel:(RDBRequestModel *)requestModel;
+ (HTTPMethod)methodWithRequestModel:(RDBRequestModel *)requestModel;
+ (NSDictionary *)headersWithRequestModel:(RDBRequestModel *)requestModel;
+ (id)requestObjectWithRequestModel:(RDBRequestModel *)requestModel;

// when making instance queries
- (NSString *)pathWithRequestModel:(RDBRequestModel *)requestModel;
- (HTTPMethod)methodWithRequestModel:(RDBRequestModel *)requestModel;\
- (NSDictionary *)headersWithRequestModel:(RDBRequestModel *)requestModel;
- (id)requestObjectWithRequestModel:(RDBRequestModel *)requestModel;

// converting to json
- (NSDictionary *)dictionaryRepresentation;
- (void)patchWithDictionary:(NSDictionary*)dict;

// kind of delegate methods
- (void)requestModelWillStartExecuting:(RDBRequestModel *)requestModel;
- (void)requestModelDidFinishExecuting:(RDBRequestModel *)requestModel;

@end