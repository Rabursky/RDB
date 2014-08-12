//
//  RDBCacheObject.h
//  Bekon
//
//  Created by Marcin Raburski on 12.03.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RDBCacheObjectTypeUnknown,
    RDBCacheObjectTypeImage
} RDBCacheObjectType;

@interface RDBCacheObject : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSDate *lastUsedDate;
@property (nonatomic) RDBCacheObjectType type;
@property (nonatomic) NSTimeInterval cacheTime;

- (RDBCacheObject *)initWithSerializedString:(NSString *)string;
- (NSString *)serializedString;

@end
