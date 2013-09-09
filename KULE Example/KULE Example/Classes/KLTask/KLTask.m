//
//  KLTask.m
//  KULE Example
//
//  Created by Marcin Raburski on 04.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "KLTask.h"

@implementation KLTask

+ (NSString*)RESTPath {
    return @"tasks";
}

+ (NSString*)jsonObjectKeyPath {
    return nil;
}

+ (NSString*)jsonObjectsKeyPath {
    return nil;
}

+ (NSDictionary*)jsonKeyPathToAttributesMapping {
    return @{@"name":@"name",
             @"author":@"author",
             @"date":@"date"};
}

+ (RDBObjectCachePolicy)cachePolicy {
    return RDBObjectCachePolicyNoCache;
}

@end
