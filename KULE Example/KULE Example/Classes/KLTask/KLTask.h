//
//  KLTask.h
//  KULE Example
//
//  Created by Marcin Raburski on 04.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDBObject.h"
#import "RDBManagedObject.h"
//#import "NSDate+JSONProtocol.h"

@interface KLTask : RDBManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate *date;

+ (NSString*)RESTPath;

@end
