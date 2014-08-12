//
//  NSObject+Property.m
//  KULE Example
//
//  Created by Marcin Raburski on 10.08.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import "NSObject+Property.h"
#import <objc/runtime.h>

@implementation NSObject (Property)

+ (NSArray *)propertyNames {
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

- (NSArray *)propertyNames {
    return [[self class] propertyNames];
}

+ (NSString *)classNameOfPropertyWithName:(NSString*)name {
    objc_property_t property = class_getProperty(self, [name UTF8String]);
    NSString* propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
    NSArray* splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@"\""];
    if ([splitPropertyAttributes count] >= 2) {
        return [splitPropertyAttributes objectAtIndex:1];
    }
    return nil;
}

- (NSString *)classNameOfPropertyWithName:(NSString*)name {
    return [[self class] classNameOfPropertyWithName:name];
}

@end
