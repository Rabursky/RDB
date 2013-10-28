//
//  RDBObjectRefFactory.h
//  Bekon
//
//  Created by Marcin Raburski on 29.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDBObjectRefFactory : NSObject

@property (nonatomic, strong) Class type;

+ (instancetype)objectFactoryWithClass:(Class)type;
- (id)objectWithJSONValue:(id)value;

@end
