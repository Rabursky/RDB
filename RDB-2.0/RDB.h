//
//  RDB.h
//  REST
//
//  Created by Marcin Raburski on 30.08.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "RDBCoreData.h"

typedef NS_ENUM(int, RDBOperation) {
    RDBOperationNone = 0,
    RDBOperationGet = 1<<1,
    RDBOperationUpdate = 1<<2,
    RDBOperationDelete = 1<<3,
    RDBOperationCreate = 1<<4,
    RDBOperationAll = 0xF
};

typedef RDBOperation RDBOperationMask;

#define HTTP_METHOD_PUT @"PUT"
#define HTTP_METHOD_GET @"GET"
#define HTTP_METHOD_POST @"POST"
#define HTTP_METHOD_PATCH @"PATCH"
#define HTTP_METHOD_DELETE @"DELETE"

typedef NS_ENUM(int, HTTPMethod) {
    HTTPMethodUnknown = 0,
    HTTPMethodGET,
    HTTPMethodPUT,
    HTTPMethodPOST,
    HTTPMethodPATCH,
    HTTPMethodDELETE,
    HTTPMethodHEAD
};

@class RDBRequestModel;
@class RDBResponse;
@class RDB;

typedef void (^RDBResponseBlock)(RDBResponse *response); // object, metadata, error
typedef void (^RDBCompletionBlock)(id object, id metadata, NSError* error); // object, metadata, error
typedef id (^RDBReplaceBlock)(id object); // object, metadata, error

@interface RDB : NSObject

@property (nonatomic) AFHTTPSessionManager *sessionManager;

// Just BASE URL like "127.0.0.1", without /v1
@property (nonatomic, strong) NSURL *url;

// If you have API v1, user urlPostfix as @"/v1"
@property (nonatomic, strong) NSString *urlPostfix;

// for automatic coreData updates
@property (nonatomic, strong) RDBCoreData *coreData;

// preconfigured for Kule
@property (nonatomic, strong) NSString *jsonMetaKeyPath; // no object at keyPath = no meta
@property (nonatomic, strong) NSString *jsonObjectKeyPath; // keyPath for object at eg /users/id
@property (nonatomic, strong) NSString *jsonObjectsKeyPath; // keyPath for objects at eg /users
@property (nonatomic, strong) NSString *jsonResponseCodeKeyPath; // code != 2xx => error
@property (nonatomic, strong) NSString *jsonErrorMessageKeyPath; // added to NSError along with errorCode

@property (nonatomic) HTTPMethod operationGetMethod; // by default: GET
@property (nonatomic) HTTPMethod operationUpdateMethod; // by default: PATCH
@property (nonatomic) HTTPMethod operationDeleteMethod; // by default: DELETE
@property (nonatomic) HTTPMethod operationCreateMethod;

// custom HTTP Headers will be added to each request
@property (nonatomic, retain) NSDictionary *HTTPHeaders;

+ (instancetype)sharedDB;
- (void)executeRequestModel:(RDBRequestModel *)model withResponseBlock:(RDBResponseBlock)responseBlock;

- (void)retainNetworkActivity;
- (void)releaseNetworkActivity;
    
@end
