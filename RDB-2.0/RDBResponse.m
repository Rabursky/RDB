//
//  RDBResponse.m
//  KULE Example
//
//  Created by Marcin Raburski on 10.08.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import "RDBResponse.h"
#import "NSObject+NSValueCodingWithNil.h"

@class RDBManagedObject;

@implementation RDBResponse

+ (instancetype)responseWithRequestModel:(RDBRequestModel *)requestModel {
    return [[self alloc] initWithRequestModel:requestModel];
}

- (instancetype)initWithRequestModel:(RDBRequestModel *)requestModel {
    if (self = [super init]) {
        self.requestModel = requestModel;
    }
    return self;
}

- (void)requestModelWillStartExecuting {
    [self.requestModel.instance requestModelWillStartExecuting:self.requestModel];
}

- (void)requestModelDidFinishExecuting {
    if (!self.error) {
        [self parseResponseObject];
        [self passRequestModelDidFinishExecuting];
    }
}

- (void)parseResponseObject {
    if (self.responseObject) {
        if (self.requestModel.instance) {
            NSString *jsonKeyPath = [self.requestModel.instance jsonObjectKeyPath];
            id object = [self.responseObject valueForKeyPathWithNil:jsonKeyPath];
            [self.requestModel.instance pathWithDictionary:object];
            self.object = self.requestModel.instance;
        } else {
            NSString *jsonKeyPath = [self.requestModel.type jsonObjectsKeyPath];
            id object = [self.responseObject valueForKeyPathWithNil:jsonKeyPath];
            if ([object isKindOfClass:[NSArray class]]) {
                self.object = [self.requestModel.type instancesWithArray:object];
            } else {
                self.object = [self.requestModel.type instanceWithDictionary:object];
            }
            
        }
    }
}

- (void)passRequestModelDidFinishExecuting {
    if ([self.object conformsToProtocol:@protocol(RDBObjectProtocol)]) {
        [self.object requestModelDidFinishExecuting:self.requestModel];
    } else if ([self.object isKindOfClass:[NSArray class]]) {
        for (id object in self.object) {
            if ([object conformsToProtocol:@protocol(RDBObjectProtocol)]) {
                [object requestModelDidFinishExecuting:self.requestModel];
            }
        }
    }
    if (self.object != self.requestModel.instance && [self.requestModel.instance conformsToProtocol:@protocol(RDBObjectProtocol)]) {
        [self.requestModel.instance requestModelDidFinishExecuting:self.requestModel];
    }
}


@end
