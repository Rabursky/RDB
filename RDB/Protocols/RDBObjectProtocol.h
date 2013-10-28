//
//  RDBObjectProtocol.h
//  REST
//
//  Created by Marcin Raburski on 04.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RDBObjectCachePolicySession, // caches results across one session
    RDBObjectCachePolicyNoCache, // always pulls new data
//    RDBObjectCachePolicyOneDay, 
} RDBObjectCachePolicy;

@protocol RDBObjectProtocol <NSObject>

@required;
+ (NSString*)RESTPath;
+ (NSString*)jsonObjectKeyPath;
+ (NSString*)jsonObjectsKeyPath;
+ (NSDictionary*)jsonKeyPathToAttributesMapping;

@optional;
// if some objects are in the array
// we have to define what kind of objects should it be
+ (NSDictionary*)jsonKeyPathToClassMapping;
+ (RDBObjectCachePolicy)cachePolicy;


- (instancetype)initWithID:(NSString*)uniqueID;
- (NSString*)_id;
- (BOOL)isRef;
- (void)updateID:(NSString*)uniqueID;

@end