//
//  NSDate+JSONProtocol.h
//  REST
//
//  Created by Marcin Raburski on 09.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDBObjectJSONProtocol.h"

@interface CLLocation (JSONProtocol) <RDBObjectJSONProtocol>

+ (instancetype)objectWithJSONValue:(id)value;
- (id)JSONValue;

@end
