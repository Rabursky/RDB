//
//  RDBRequestModel.h
//  KULE Example
//
//  Created by Marcin Raburski on 08.08.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDBObjectProtocol.h"
#import "RDB.h"

@interface RDBRequestModel : NSObject

@property (nonatomic, strong) id<RDBObjectProtocol> instance;
@property (nonatomic, strong) Class<RDBObjectProtocol> type;

@property (nonatomic) RDBOperation operation;
@property (nonatomic) HTTPMethod method;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) id requestObject;


@end
