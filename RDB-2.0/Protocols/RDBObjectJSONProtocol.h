//
//  RDBObjectJSONProtocol.h
//  REST
//
//  Created by Marcin Raburski on 08.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RDBObjectJSONProtocol <NSObject>

+ (instancetype)objectWithJSONValue:(id)value;
- (id)JSONValue;

@end
