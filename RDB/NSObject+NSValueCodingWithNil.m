//
//  NSObject+NSValueCodingWithNil.m
//  REST
//
//  Created by Marcin Raburski on 04.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "NSObject+NSValueCodingWithNil.h"

@implementation NSObject (NSValueCodingWithNil)

- (id)valueForKeyPathWithNil:(NSString *)keyPath;{
    if (!keyPath || keyPath.length <= 0) {
        return self;
    }
    return [self valueForKeyPath:keyPath];
}

@end
