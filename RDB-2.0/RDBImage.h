//
//  RDBImage.h
//  Bekon
//
//  Created by Marcin Raburski on 12.03.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDBObjectJSONProtocol.h"
#import "RDB.h"

typedef void (^RDBImageBlock)(UIImage *image, NSError* error);

@interface RDBImage : NSObject <RDBObjectJSONProtocol>

@property (nonatomic, strong) NSString *url;
@property (nonatomic) NSTimeInterval cacheTime;

@property (nonatomic) BOOL clipToRound;

+ (instancetype)objectWithJSONValue:(id)value;
- (id)JSONValue;

- (id)initWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image clipToRound:(BOOL)clip;
- (void)imageWithCompletionBlock:(RDBImageBlock)imageBlock;

@end
