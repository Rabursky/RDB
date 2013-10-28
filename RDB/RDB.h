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
typedef void (^RDBHTTPRequestFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON);

@class RDB;

@protocol RDBErrorDelegate <NSObject>

- (void)RDB:(RDB*)rdb didFinishRequestWithError:(NSError*)error metadata:(id)metadata object:(id)object andRetryInvocation:(NSInvocation*)invocation;

@end

@interface RDB : NSObject

// Just BASE URL like "127.0.0.1", without /v1
@property (nonatomic, retain) NSURL *url;

// If you have API v1, user urlPostfix as @"/v1"
@property (nonatomic, retain) NSString *urlPostfix;

// preconfigured for Kule
@property (nonatomic, retain) NSString *jsonMetaKeyPath; // no object at keyPath = no meta
@property (nonatomic, retain) NSString *jsonObjectKeyPath; // keyPath for object at eg /users/id
@property (nonatomic, retain) NSString *jsonObjectsKeyPath; // keyPath for objects at eg /users
@property (nonatomic, retain) NSString *jsonResponseCodeKeyPath; // code != 2xx => error
@property (nonatomic, retain) NSString *jsonErrorMessageKeyPath; // added to NSError along with errorCode

@property (nonatomic, retain) NSString *HTTPMethodObjectGet; // by default: GET
@property (nonatomic, retain) NSString *HTTPMethodObjectUpdate; // by default: PATCH
@property (nonatomic, retain) NSString *HTTPMethodObjectRemove; // by default: DELETE
@property (nonatomic, retain) NSString *HTTPMethodObjectCreate; // by default: POST

// custom HTTP Headers will be added to each request
@property (nonatomic, retain) NSDictionary *HTTPHeaders;

// if error occurs, it is posted as argument in completion block
// and also passed to this delegate
@property (nonatomic, assign) id <RDBErrorDelegate> errorDelegate;

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

// Re-downloads all data from the DB and patches current object
- (void)updateObject:(id<RDBObjectProtocol>)object;
- (void)updateObject:(id<RDBObjectProtocol>)object withCompletionBlock:(RDBCompletionBlock)completionBlock;

@end
