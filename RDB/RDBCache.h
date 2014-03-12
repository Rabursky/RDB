//
//  RDBCache.h
//  Bekon
//
//  Created by Marcin Raburski on 12.03.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDBCache : NSObject

+ (RDBCache *)sharedCache;

- (void)setObject:(id)object forKey:(NSString *)key withCacheTime:(NSTimeInterval)time;
- (id)objectForKey:(id)key;

- (void)clearCache;

@end
