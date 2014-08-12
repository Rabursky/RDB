//
//  NSDate+JSONProtocol.m
//  REST
//
//  Created by Marcin Raburski on 09.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "NSDate+JSONProtocol.h"

@implementation NSDate (JSONProtocol)

+ (instancetype)objectWithJSONValue:(id)value {
    NSDate *object;
    if (value) {
        if ([value isKindOfClass:[NSNumber class]]) {
            object = [[NSDate alloc] initWithTimeIntervalSince1970:[value doubleValue]];
        } else if([value isKindOfClass:[NSString class]]) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            object = [df dateFromString:value];
            if (!object) {
                [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                object = [df dateFromString:value];
            }
        }
    } else {
        return nil;
    }
    return object;
}

- (id)JSONValue {
    return @([self timeIntervalSince1970]);
}

@end
