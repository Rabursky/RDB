//
//  NSObject+Property.h
//  KULE Example
//
//  Created by Marcin Raburski on 10.08.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Property)

+ (NSArray *)propertyNames;
- (NSArray *)propertyNames;
+ (NSString*)classNameOfPropertyWithName:(NSString*)name;
- (NSString*)classNameOfPropertyWithName:(NSString*)name;

@end
