//
//  RDBObjectRefFactory.m
//  Bekon
//
//  Created by Marcin Raburski on 29.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "RDBObjectRefFactory.h"
#import "RDBObject.h"

@implementation RDBObjectRefFactory

+ (instancetype)objectFactoryWithClass:(Class)type {
    RDBObjectRefFactory *factory = [[self alloc] init];
    factory.type = type;
    return factory;
}

- (id)objectWithJSONValue:(id)value {
    RDBObject* object = [[self.type alloc] initWithID:value];
    [object setRef:YES];
    return object;
}


@end
