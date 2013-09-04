//
//  RDB.m
//  REST
//
//  Created by Marcin Raburski on 30.08.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "RDB.h"
#import "NSObject+NSValueCodingWithNil.h"

#define HTTP_METHOD_PUT @"PUT"
#define HTTP_METHOD_GET @"GET"
#define HTTP_METHOD_POST @"POST"
#define HTTP_METHOD_PATCH @"PATCH"
#define HTTP_METHOD_DELETE @"DELETE"

#define RDB_ERROR_CANNOT_DELETE_LOCAL_OBJECT_CODE 400
#define RDB_ERROR_CANNOT_DELETE_LOCAL_OBJECT_MESSAGE @"Cannot remove local object. (without _id)"

@interface RDB ()

@property (nonatomic) AFHTTPClient *client;

@end

@implementation RDB

#pragma mark - Class methods

static RDB *sharedDB;
+ (instancetype)sharedDB {
    @synchronized(self) {
        if (!sharedDB) {
            sharedDB = [[RDB alloc] init];
        }
    }
    return sharedDB;
}
+ (void)objectOfClass:(Class<RDBObjectProtocol>)type withID:(NSString*)objectID withCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[self sharedDB] objectOfClass:type withID:objectID withCompletionBlock:completionBlock];
}

+ (void)objectsOfClass:(Class<RDBObjectProtocol>)type withCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[self sharedDB] objectsOfClass:type withCompletionBlock:completionBlock];
}

+ (void)updateObject:(id)object {
    [[self sharedDB] updateObject:object];
}

+ (void)updateObject:(id)object withCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[self sharedDB] updateObject:object withCompletionBlock:completionBlock];
}

+ (void)removeObject:(id<RDBObjectProtocol>)object {
    [[self sharedDB] removeObject:object];
}

+ (void)removeObject:(id<RDBObjectProtocol>)object withCompletionBlock:(RDBCompletionBlock)completionBlock {
    [[self sharedDB] removeObject:object withCompletionBlock:completionBlock];
}

#pragma mark - Properties custom getters

- (NSString*)jsonMetaKeyPath {
    if (!_jsonMetaKeyPath) {
        return @"meta";
    }
    return _jsonMetaKeyPath;
}

- (NSString*)jsonObjectsKeyPath {
    if (!_jsonObjectsKeyPath) {
        return @"objects";
    }
    return _jsonObjectsKeyPath;
}

- (NSString*)jsonObjectKeyPath {
    if (!_jsonObjectKeyPath) {
        return @"";
    }
    return _jsonObjectKeyPath;
}

- (NSString*)jsonResponseCodeKeyPath {
    if (!_jsonResponseCodeKeyPath) {
        return @"error";
    }
    return _jsonResponseCodeKeyPath;
}

- (NSString*)jsonErrorMessageKeyPath {
    if (!_jsonErrorMessageKeyPath) {
        return @"message";
    }
    return _jsonErrorMessageKeyPath;
}

- (NSString*)HTTPMethodObjectGet {
    if (!_HTTPMethodObjectGet) {
        return HTTP_METHOD_GET;
    }
    return _HTTPMethodObjectGet;
}

- (NSString*)HTTPMethodObjectUpdate {
    if (!_HTTPMethodObjectUpdate) {
        return HTTP_METHOD_PATCH;
    }
    return _HTTPMethodObjectUpdate;
}

- (NSString*)HTTPMethodObjectRemove {
    if (!_HTTPMethodObjectRemove) {
        return HTTP_METHOD_DELETE;
    }
    return _HTTPMethodObjectRemove;
}

- (NSString*)HTTPMethodObjectCreate {
    if (!_HTTPMethodObjectCreate) {
        return HTTP_METHOD_POST;
    }
    return _HTTPMethodObjectCreate;
}

- (AFHTTPClient*)client {
    @synchronized(self) {
        if (!_client || ![_client.baseURL isEqual:self.url]) {
            _client = [[AFHTTPClient alloc] initWithBaseURL:self.url];
            [_client setParameterEncoding:AFJSONParameterEncoding];
        }
    }
    return _client;
}

#pragma mark - API Request Methods

- (NSMutableURLRequest*)requestWithMethod:(NSString*)method andPath:(NSString*)path andParameters:(id)parameters {
    NSMutableURLRequest *urlRequest;
    if ([method isEqualToString:HTTP_METHOD_GET]) {
        // Get method should not have HTTP body, or even headers connected
        urlRequest = [NSMutableURLRequest requestWithURL:[self.url URLByAppendingPathComponent:path]];
    } else {
        urlRequest = [self.client requestWithMethod:method path:path parameters:parameters];
        [urlRequest addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    for (NSString *header in self.HTTPHeaders.allKeys) {
        [urlRequest addValue:[self.HTTPHeaders objectForKey:header] forHTTPHeaderField:header];
    }
    return urlRequest;
}

- (void)objectOfClass:(Class)type withID:(NSString*)objectID withCompletionBlock:(RDBCompletionBlock)completionBlock {
    NSMutableURLRequest *request = [self requestWithMethod:self.HTTPMethodObjectGet andPath:[self RESTPathOfObjectWithClass:type andObjectID:objectID] andParameters:nil];
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (completionBlock) {
            completionBlock([self createInstanceOfClass:type withDictionary:[self dictionaryRepresentationOfObjectWithClass:type fromResponse:JSON]], [self metadataWithJSON:JSON], [self errorWithError:nil andJSON:JSON]);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (completionBlock) {
            completionBlock(nil, [self metadataWithJSON:JSON], [self errorWithError:error andJSON:JSON]);
        }
    }];
    [requestOperation start];
}

- (void)objectsOfClass:(Class)type withCompletionBlock:(RDBCompletionBlock)completionBlock {
    NSMutableURLRequest *request = [self requestWithMethod:self.HTTPMethodObjectGet andPath:[self RESTPathOfObjectsWithClass:type] andParameters:nil];
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (completionBlock) {
            NSArray *representations = [self dictionaryRepresentationOfObjectsWithClass:type fromResponse:JSON];
            NSMutableArray *objects = [[NSMutableArray alloc] init];
            for (NSDictionary *representation in representations) {
                [objects addObject:[self createInstanceOfClass:type withDictionary:representation]];
            }
            completionBlock(objects, [self metadataWithJSON:JSON], [self errorWithError:nil andJSON:JSON]);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (completionBlock) {
            completionBlock(nil, [self metadataWithJSON:JSON], [self errorWithError:error andJSON:JSON]);
        }
    }];
    [requestOperation start];
}

- (void)updateObject:(id<RDBObjectProtocol>)object {
    [self updateObject:object withCompletionBlock:nil];
}

- (void)updateObject:(id<RDBObjectProtocol>)object withCompletionBlock:(RDBCompletionBlock)completionBlock {
    NSDictionary *objectRepresentation = [self dictionaryRepresentationOfObject:object];
    NSMutableURLRequest *request;
    if (object._id) { // if there is ID, we would like to update the object
        request = [self requestWithMethod:self.HTTPMethodObjectUpdate andPath:[self RESTPathOfObject:object] andParameters:objectRepresentation];
    } else { // if there is no ID, we would like to create one
        request = [self requestWithMethod:self.HTTPMethodObjectCreate andPath:[self RESTPathOfObjectsWithClass:[object class]] andParameters:objectRepresentation];
    }
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON) {
            [self pathObject:object withDictionary:[self dictionaryRepresentationOfObjectWithClass:[object class] fromResponse:JSON]];
        }
        if (completionBlock) {
            completionBlock(object, [self metadataWithJSON:JSON], [self errorWithError:nil andJSON:JSON]);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (completionBlock) {
            completionBlock(object, [self metadataWithJSON:JSON], [self errorWithError:error andJSON:JSON]);
        }
    }];
    [requestOperation start];
}

- (void)removeObject:(id<RDBObjectProtocol>)object {
    [self removeObject:object withCompletionBlock:nil];
}

- (void)removeObject:(id<RDBObjectProtocol>)object withCompletionBlock:(RDBCompletionBlock)completionBlock {
    if (object._id) {
        NSMutableURLRequest *request = [self requestWithMethod:self.HTTPMethodObjectRemove andPath:[self RESTPathOfObject:object] andParameters:nil];
        AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            if (completionBlock) {
                completionBlock(object, [self metadataWithJSON:JSON], [self errorWithError:nil andJSON:JSON]);
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            if (completionBlock) {
                completionBlock(object, [self metadataWithJSON:JSON], [self errorWithError:error andJSON:JSON]);
            }
        }];
        [requestOperation start];
    } else {
        if (completionBlock) {
            completionBlock(object, nil, [NSError errorWithDomain:@"local" code:RDB_ERROR_CANNOT_DELETE_LOCAL_OBJECT_CODE userInfo:@{NSLocalizedDescriptionKey:RDB_ERROR_CANNOT_DELETE_LOCAL_OBJECT_MESSAGE}]);
        }
    }
}

#pragma mark  - Helper methods

- (NSString*)RESTPathOfObjectsWithClass:(Class<RDBObjectProtocol>)type {
    if (self.urlPostfix) {
        return [NSString stringWithFormat:@"%@%@", self.urlPostfix, [type RESTPath]];
    }
    return [type RESTPath];
}

- (NSString*)RESTPathOfObject:(id<RDBObjectProtocol>)object {
    return [self RESTPathOfObjectWithClass:[object class] andObjectID:object._id];
}

- (NSString*)RESTPathOfObjectWithClass:(Class<RDBObjectProtocol>)type andObjectID:(NSString*)objectID {
    if (self.urlPostfix) {
        return [NSString stringWithFormat:@"%@%@/%@", self.urlPostfix, [type RESTPath], objectID];
    }
    return [NSString stringWithFormat:@"%@/%@", [type RESTPath], objectID];
}

- (NSArray*)dictionaryRepresentationOfObjectsWithClass:(Class)type fromResponse:(NSDictionary*)JSON {
    NSDictionary *contentPlural = [JSON valueForKeyPathWithNil:self.jsonObjectsKeyPath];
    return [contentPlural valueForKeyPathWithNil:[type jsonObjectsKeyPath]];
}

- (NSDictionary*)dictionaryRepresentationOfObjectWithClass:(Class)type fromResponse:(NSDictionary*)JSON {
    NSDictionary *contentSingular = [JSON valueForKeyPathWithNil:self.jsonObjectKeyPath];
    return [contentSingular valueForKeyPathWithNil:[type jsonObjectKeyPath]];
}

- (id)createInstanceOfClass:(Class)type withDictionary:(NSDictionary*)dict {
    id instance = [[type alloc] init];
    [self pathObject:instance withDictionary:dict];
    return instance;
}

- (NSDictionary*)dictionaryRepresentationOfObject:(id)object {
    NSDictionary *attributes = [[object class] jsonKeyPathToAttributesMapping];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *keypath in attributes.allKeys) {
        NSString *property = [attributes objectForKey:keypath];
        id value = [object valueForKeyPathWithNil:property];
        if (value) {
            [dict setObject:value forKey:keypath];
        }
    }
    return dict;
}

- (void)pathObject:(id)instance withDictionary:(NSDictionary*)dict {
    NSDictionary *attributes = [[instance class] jsonKeyPathToAttributesMapping];
    if ([dict.allKeys containsObject:@"_id"]) {
        [instance updateID:[dict objectForKey:@"_id"]];
    }
    for (NSString *keypath in attributes.allKeys) {
        id value = [dict valueForKeyPathWithNil:keypath];
        NSString *property = [attributes objectForKey:keypath];
        if (value && property) {
            [instance setValue:value forKeyPath:property];
        }
    }
}

- (NSError*)errorWithError:(NSError*)error andJSON:(NSDictionary*)JSON {
    if (error) {
        return error;
    }
    NSNumber *responseCode = [JSON valueForKeyPathWithNil:self.jsonResponseCodeKeyPath];
    NSString *errorMessage = [JSON valueForKeyPathWithNil:self.jsonErrorMessageKeyPath];
    if ([responseCode intValue] > 0 && ([responseCode intValue] < 200 || [responseCode intValue] > 299)) {
        if (!errorMessage) {
            errorMessage = [NSString stringWithFormat:@"Error with code: %d", [responseCode intValue]];
        }
        return [NSError errorWithDomain:@"local" code:[responseCode intValue] userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
    }
    return nil;
}

- (id)metadataWithJSON:(NSDictionary*)JSON {
    if (self.jsonMetaKeyPath) {
        NSDictionary *dict = [JSON valueForKeyPathWithNil:self.jsonMetaKeyPath];
        if (dict) {
            id metaObject;
            if (self.metaObjectClass) {
                metaObject = [[self.metaObjectClass alloc] init];
                [self pathObject:metaObject withDictionary:dict];
            } else {
                metaObject = dict;
            }
            return metaObject;
        }
    }
    return nil;
}


@end