//
//  NSMutableDictionary+ObjectKeyPath.h
//  Face2Face
//
//  Created by Marcin Raburski on 28.10.2013.
//  Copyright (c) 2013 Paweł Sołyga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (ObjectKeyPath)

- (void)setObject:(id)anObject forKeyPath:(NSString <NSCopying>*)aKey;

@end
