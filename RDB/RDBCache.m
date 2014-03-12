//
//  RDBCache.m
//  Bekon
//
//  Created by Marcin Raburski on 12.03.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import "RDBCache.h"
#import "RDBCacheObject.h"

@interface RDBCache ()

// dictionary keys are cache object keys
@property (nonatomic, strong) NSMutableDictionary *cacheObjects;

@end

@implementation RDBCache

static RDBCache *_cache;
+ (RDBCache *)sharedCache {
    if (!_cache) {
        _cache = [RDBCache new];
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/Cache/Files", [_cache applicationDocumentsDirectory]] withIntermediateDirectories:YES attributes:nil error:nil];
        [_cache loadCachedObjects];
        [_cache clearOldCache];
    }
    return _cache;
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
- (NSString *)randomString:(int)len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

- (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}

- (NSString *)pathForFileWithName:(NSString *)name {
    return [[self applicationDocumentsDirectory] stringByAppendingFormat:@"/Cache/Files/%@", name];
}

- (NSString *)pathForMetaWithName:(NSString *)name {
    return [[self applicationDocumentsDirectory] stringByAppendingFormat:@"/Cache/%@.plist", name];
}

- (void)setObject:(id)object forKey:(NSString *)key withCacheTime:(NSTimeInterval)time {
    RDBCacheObject *cacheObject = [self.cacheObjects objectForKey:key];
    if (!cacheObject) {
        cacheObject = [RDBCacheObject new];
        cacheObject.fileName = [self randomString:10];
    }
    cacheObject.lastUsedDate = [NSDate date];
    cacheObject.cacheTime = time;
    cacheObject.key = key;
    if ([object isKindOfClass:[UIImage class]]) {
        cacheObject.type = RDBCacheObjectTypeImage;
        [UIImagePNGRepresentation((UIImage *)object) writeToFile:[self pathForFileWithName:cacheObject.fileName] atomically:YES];
    }
    
    [self.cacheObjects setObject:cacheObject forKey:key];
    [self synchronize];
}

- (id)objectForKey:(id)key {
    RDBCacheObject *cacheObject = [self.cacheObjects objectForKey:key];
    if (cacheObject) {
        if ([(NSDate *)[cacheObject.lastUsedDate dateByAddingTimeInterval:cacheObject.cacheTime] compare:[NSDate date]] == NSOrderedAscending) {
            [[NSFileManager defaultManager] removeItemAtPath:[self pathForFileWithName:cacheObject.fileName] error:nil];
            [self.cacheObjects removeObjectForKey:cacheObject.key];
            return nil;
        }
        switch (cacheObject.type) {
            case RDBCacheObjectTypeImage:
                return [UIImage imageWithContentsOfFile:[self pathForFileWithName:cacheObject.fileName]];
                break;
                
            default:
                break;
        }
    }
    return nil;
}

- (void)clearCache {
    for (RDBCacheObject *object in self.cacheObjects.allValues) {
        [[NSFileManager defaultManager] removeItemAtPath:[self pathForFileWithName:object.fileName] error:nil];
    }
    self.cacheObjects = [NSMutableDictionary new];
    [self synchronize];
}

- (void)loadCachedObjects {
    self.cacheObjects = [NSMutableDictionary dictionaryWithContentsOfFile:[self pathForMetaWithName:@"objects"]];
    if (!self.cacheObjects) {
        self.cacheObjects = [NSMutableDictionary new];
    }
    for (NSString *key in self.cacheObjects.allKeys) {
        NSString *string = [self.cacheObjects objectForKey:key];
        [self.cacheObjects setObject:[[RDBCacheObject alloc] initWithSerializedString:string] forKey:key];
    }
}

- (void)synchronize {
    NSMutableDictionary *dict = [self.cacheObjects mutableCopy];
    for (NSString *key in self.cacheObjects.allKeys) {
        RDBCacheObject *object = [self.cacheObjects objectForKey:key];
        [dict setObject:[object serializedString] forKey:key];
    }
    [dict writeToFile:[self pathForMetaWithName:@"objects"] atomically:YES];
}

- (void)clearOldCache {
    NSArray *keys = self.cacheObjects.allKeys;
    for (NSString *key in keys) {
        RDBCacheObject *object = [self.cacheObjects objectForKey:key];
        if ([(NSDate *)[object.lastUsedDate dateByAddingTimeInterval:object.cacheTime] compare:[NSDate date]] == NSOrderedAscending) {
            [[NSFileManager defaultManager] removeItemAtPath:[self pathForFileWithName:object.fileName] error:nil];
            [self.cacheObjects removeObjectForKey:key];
        }
    }
}

@end
