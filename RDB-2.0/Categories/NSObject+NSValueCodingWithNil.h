//
//  NSObject+NSValueCodingWithNil.h
//  REST
//
//  Created by Marcin Raburski on 04.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSValueCodingWithNil)

- (id)valueForKeyPathWithNil:(NSString *)keyPath;

@end
