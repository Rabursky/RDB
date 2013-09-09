//
//  KLTask.h
//  KULE Example
//
//  Created by Marcin Raburski on 04.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDBObject.h"

@interface KLTask : RDBObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate *date;

+ (NSString*)RESTPath;
+ (NSString*)jsonObjectKeyPath;
+ (NSString*)jsonObjectsKeyPath;
+ (NSDictionary*)jsonKeyPathToAttributesMapping;
+ (RDBObjectCachePolicy)cachePolicy;

@end
