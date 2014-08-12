//
//  RDBCacheObject.m
//  Bekon
//
//  Created by Marcin Raburski on 12.03.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import "RDBCacheObject.h"

@implementation RDBCacheObject

- (RDBCacheObject *)initWithSerializedString:(NSString *)string {
    NSArray *split = [string componentsSeparatedByString:@"$"];
    if (self = [super init]) {
        self.fileName = split[0];
        self.type = [split[1] intValue];
        self.lastUsedDate = [NSDate dateWithTimeIntervalSince1970:[split[2] doubleValue]];
        self.cacheTime = [split[3] doubleValue];
    }
    return self;
}

- (NSString *)serializedString {
    return [NSString stringWithFormat:@"%@$%d$%f$%f",self.fileName,self.type,[self.lastUsedDate timeIntervalSince1970], self.cacheTime];
}


@end
