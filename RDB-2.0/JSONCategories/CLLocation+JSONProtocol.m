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
    if (value && [value isKindOfClass:[NSDictionary class]] && [value.allKeys containsObject:@"latitude"] && [value.allKeys containsObject:@"longitude"]) {
        id latitide = [value objectForKey:@"latitude"];
        id longitude = [value objectForKey:@"longitude"];
        if ([latitide isKindOfClass:[NSString class]] && [latitide length] == 0) {
            return nil;
        }
        if ([longitude isKindOfClass:[NSString class]] && [latitide length] == 0) {
            return nil;
        }
        if ([latitide doubleValue] == 0 || [longitude doubleValue] == 0) {
            return nil;
        }
        return [[CLLocation alloc] initWithLatitude:[latitide doubleValue] longitude:[longitude doubleValue]];
    }
    return nil;
}

- (id)JSONValue {
    return @{@"latitude":@(self.coordinate.latitude),@"longitude":@(self.coordinate.longitude)};
}

@end
