//
//  NSMutableDictionary+ObjectKeyPath.m
//  Face2Face
//
//  Created by Marcin Raburski on 28.10.2013.
//  Copyright (c) 2013 Paweł Sołyga. All rights reserved.
//

#import "NSMutableDictionary+ObjectKeyPath.h"

@implementation NSMutableDictionary (ObjectKeyPath)

- (void)setObject:(id)anObject forKeyPath:(NSString <NSCopying>*)aKey {
    NSArray *slices = [aKey componentsSeparatedByString:@"."];
    NSMutableDictionary *currentDict = self;
    for (int i = 0; i < slices.count - 1; i++) {
        NSString *key = [slices objectAtIndex:i];
        if (![currentDict.allKeys containsObject:key]) {
            [currentDict setObject:[NSMutableDictionary new] forKey:key];
            
        }
        currentDict = [currentDict objectForKey:key];
    }
    [currentDict setObject:anObject forKey:[slices lastObject]];
}

@end
