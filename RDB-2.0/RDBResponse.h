//
//  RDBResponse.h
//  KULE Example
//
//  Created by Marcin Raburski on 10.08.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDBRequestModel.h"

@interface RDBResponse : NSObject

@property (nonatomic, strong) RDBRequestModel *requestModel;

@property (nonatomic, strong) NSError *error;
@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong) id responseObject; // whole JSON /

@property (nonatomic, strong) id metadata; // extracted meta
@property (nonatomic, strong) id object; // extracted object/s

+ (instancetype)responseWithRequestModel:(RDBRequestModel *)requestModel;
- (instancetype)initWithRequestModel:(RDBRequestModel *)requestModel;

// called by RDB
- (void)requestModelWillStartExecuting;
- (void)requestModelDidFinishExecuting;
- (void)parseResponseObject;

@end
