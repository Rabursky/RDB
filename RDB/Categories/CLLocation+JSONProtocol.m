//
//  NSDate+JSONProtocol.m
//  REST
//
//  Created by Marcin Raburski on 09.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "CLLocation+JSONProtocol.h"

@implementation CLLocation (JSONProtocol)

+ (instancetype)objectWithJSONValue:(NSDictionary*)value {
    if (value && [value isKindOfClass:[NSDictionary class]] && [value.allKeys containsObject:@"latitude"] && [value.allKeys containsObject:@"longtitude"]) {
        return [[CLLocation alloc] initWithLatitude:[[value objectForKey:@"latitude"] doubleValue] longitude:[[value objectForKey:@"longtitude"] doubleValue]];
    }
    return nil;
}

- (id)JSONValue {
    return @{@"latitude":@(self.coordinate.latitude),@"longtitude":@(self.coordinate.longitude)};
}

@end
