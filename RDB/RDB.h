//
//  RDB.h
//  REST
//
//  Created by Marcin Raburski on 30.08.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "RDBObjectProtocol.h"


typedef void (^RDBCompletionBlock)(id object, id metadata, NSError* error); // object, metadata, error
typedef id (^RDBReplaceBlock)(id object); // object, metadata, error

@interface RDB : NSObject

// Just BASE URL like "127.0.0.1", without /v1
@property (nonatomic) NSURL *url;

// If you have API v1, user urlPostfix as @"/v1"
@property (nonatomic) NSString *urlPostfix;

// preconfigured for Kule
@property (nonatomic) NSString *jsonMetaKeyPath; // no object at keyPath = no meta
@property (nonatomic) NSString *jsonObjectKeyPath; // keyPath for object at eg /users/id
@property (nonatomic) NSString *jsonObjectsKeyPath; // keyPath for objects at eg /users
@property (nonatomic) NSString *jsonResponseCodeKeyPath; // code != 2xx => error
@property (nonatomic) NSString *jsonErrorMessageKeyPath; // added to NSError along with errorCode

@property (nonatomic) NSString *HTTPMethodObjectGet; // by default: GET
@property (nonatomic) NSString *HTTPMethodObjectUpdate; // by default: PATCH
@property (nonatomic) NSString *HTTPMethodObjectRemove; // by default: DELETE
@property (nonatomic) NSString *HTTPMethodObjectCreate; // by default: POST

// custom HTTP Headers will be added to each request
@property (nonatomic) NSDictionary *HTTPHeaders;

// metadata returned by the API can be returned as object instead of dictionary
// it is normal RDBObject, but cant be updated or removed
@property (nonatomic) Class metaObjectClass; // HAVE TO CONFORM TO <RDBObjectProtocol>

+ (instancetype)sharedDB;
+ (void)objectOfClass:(Class<RDBObjectProtocol>)type withID:(NSString*)objectID withCompletionBlock:(RDBCompletionBlock)completionBlock;
+ (void)objectsOfClass:(Class<RDBObjectProtocol>)type withCompletionBlock:(RDBCompletionBlock)completionBlock;
+ (void)saveObject:(id<RDBObjectProtocol>)object;
+ (void)saveObject:(id<RDBObjectProtocol>)object withCompletionBlock:(RDBCompletionBlock)completionBlock;
+ (void)removeObject:(id<RDBObjectProtocol>)object;
+ (void)removeObject:(id<RDBObjectProtocol>)object withCompletionBlock:(RDBCompletionBlock)completionBlock;

- (void)objectOfClass:(Class<RDBObjectProtocol>)type withID:(NSString*)objectID withCompletionBlock:(RDBCompletionBlock)completionBlock;
- (void)objectsOfClass:(Class<RDBObjectProtocol>)type withCompletionBlock:(RDBCompletionBlock)completionBlock;
- (void)saveObject:(id<RDBObjectProtocol>)object;
- (void)saveObject:(id<RDBObjectProtocol>)object withCompletionBlock:(RDBCompletionBlock)completionBlock;
- (void)removeObject:(id<RDBObjectProtocol>)object;
- (void)removeObject:(id<RDBObjectProtocol>)object withCompletionBlock:(RDBCompletionBlock)completionBlock;

@end
