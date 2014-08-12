//
//  RDB.m
//  REST
//
//  Created by Marcin Raburski on 30.08.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "RDB.h"
#import "NSObject+NSValueCodingWithNil.h"
//#import "RDBObjectJSONProtocol.h"
#import "RDBObject.h"
#import "RDBResponse.h"
//#import "NSMutableDictionary+ObjectKeyPath.h"

#define RDB_ERROR_CANNOT_DELETE_LOCAL_OBJECT_CODE 400
#define RDB_ERROR_CANNOT_DELETE_LOCAL_OBJECT_MESSAGE @"Cannot remove local object. (without _id)"

#define RDB_ERROR_CANNOT_UPDATE_LOCAL_OBJECT_CODE 400
#define RDB_ERROR_CANNOT_UPDATE_LOCAL_OBJECT_MESSAGE @"Cannot update local object. (without _id)"

@interface RDB ()

@property (atomic) NSInteger networkActivityRetainCount;

@end

@implementation RDB

#pragma mark - Class methods

static RDB *sharedDB;
+ (instancetype)sharedDB {
    @synchronized(self) {
        if (!sharedDB) {
            sharedDB = [[RDB alloc] init];
            sharedDB.operationCreateMethod = HTTPMethodPOST;
            sharedDB.operationDeleteMethod = HTTPMethodDELETE;
            sharedDB.operationGetMethod = HTTPMethodGET;
            sharedDB.operationUpdateMethod = HTTPMethodPATCH;
            sharedDB.urlPostfix = @"";
        }
    }
    return sharedDB;
}

#pragma mark - Properties custom getters

- (void)setUrlPostfix:(NSString *)urlPostfix {
    if ([urlPostfix characterAtIndex:[urlPostfix length] - 1] == '/') {
        _urlPostfix = [urlPostfix substringToIndex:[urlPostfix length] - 2];
    } else {
        _urlPostfix = urlPostfix;
    }
}

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

- (AFHTTPSessionManager *)sessionManager {
    @synchronized(self) {
        if (!_sessionManager || ![_sessionManager.baseURL isEqual:self.url]) {
            _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.url];
            _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        }
    }
    return _sessionManager;
}

#pragma mark - Network Activity Management

- (void)retainNetworkActivity {
    self.networkActivityRetainCount ++;
    [self updateNetworkActivity];
}

- (void)releaseNetworkActivity {
    self.networkActivityRetainCount --;
    [self updateNetworkActivity];
}

- (void)updateNetworkActivity {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (self.networkActivityRetainCount > 0);
}

#pragma mark - NEW IMPLEMENTATION


- (void)executeRequestModel:(RDBRequestModel *)model withResponseBlock:(RDBResponseBlock)responseBlock {
    NSString *path = [self.urlPostfix stringByAppendingFormat:@"/%@", model.path];
    RDBResponse *response = [RDBResponse responseWithRequestModel:model];
    
    // Preparning completion blocks
    void (^successBlock)(NSURLSessionDataTask *task, id responseObject) = ^void(NSURLSessionDataTask *task, id responseObject) {
        if (model.instance) {
            response.responseObject = [responseObject valueForKeyPathWithNil:self.jsonObjectKeyPath];
        } else {
            response.responseObject = [responseObject valueForKeyPathWithNil:self.jsonObjectsKeyPath];
        }
        response.metadata = [responseObject valueForKeyPathWithNil:self.jsonMetaKeyPath];
        
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            response.statusCode = ((NSHTTPURLResponse*)task.response).statusCode;
        } else {
            response.statusCode = 0;
        }

        [response requestModelDidFinishExecuting];
        responseBlock(response);
    };
    void (^failureBlock)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
        response.error = error;
        
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            response.statusCode = ((NSHTTPURLResponse*)task.response).statusCode;
        } else {
            response.statusCode = 0;
        }
        [response requestModelDidFinishExecuting];
        responseBlock(response);
    };
    
    // Settings headers
    NSMutableDictionary *headers = [self.HTTPHeaders mutableCopy];
    [headers addEntriesFromDictionary:model.headers];
    for (NSString *key in self.sessionManager.requestSerializer.HTTPRequestHeaders.allKeys) {
        if (![headers.allKeys containsObject:key]) {
            [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:key];
        }
    }
    for (NSString *key in headers.allKeys) {
        [self.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
    }
    
    [response requestModelWillStartExecuting];
    // Making request depending on method
    switch (model.method) {
        case HTTPMethodGET:
            [self.sessionManager GET:path parameters:model.requestObject success:successBlock failure:failureBlock];
            break;
        case HTTPMethodPOST:
            [self.sessionManager POST:path parameters:model.requestObject success:successBlock failure:failureBlock];
            break;
        case HTTPMethodPATCH:
            [self.sessionManager PATCH:path parameters:model.requestObject success:successBlock failure:failureBlock];
            break;
        case HTTPMethodDELETE:
            [self.sessionManager DELETE:path parameters:model.requestObject success:successBlock failure:failureBlock];
            break;
        case HTTPMethodPUT:
            [self.sessionManager PUT:path parameters:model.requestObject success:successBlock failure:failureBlock];
            break;
        case HTTPMethodHEAD: {
            [self.sessionManager HEAD:path parameters:model.requestObject success:^(NSURLSessionDataTask *task) {
                successBlock(task, nil);
            } failure:failureBlock];
        } break;
            
        default:
            break;
    }
    
}


@end
