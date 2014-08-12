//
//  RDBRequestModel.m
//  KULE Example
//
//  Created by Marcin Raburski on 08.08.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import "RDBRequestModel.h"

@implementation RDBRequestModel

//- (NSURLRequest *)requestWithRDB:(RDB *)rdb {
//    NSMutableURLRequest *urlRequest;
//    NSURL *url = [[rdb.url URLByAppendingPathComponent:rdb.urlPostfix] URLByAppendingPathComponent:self.path];
//    if ([self.method isEqualToString:HTTP_METHOD_GET]) {
//        // Get method should not have HTTP body, or even headers connected
//        urlRequest = [NSMutableURLRequest requestWithURL:url];
//    } else {
////        urlRequest = [rdb.requestOperationManager GET:<#(NSString *)#> parameters:<#(id)#> success:<#^(AFHTTPRequestOperation *operation, id responseObject)success#> failure:<#^(AFHTTPRequestOperation *operation, NSError *error)failure#>];
////        [urlRequest addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    }
//    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    for (NSString *header in rdb.HTTPHeaders.allKeys) {
//        [urlRequest addValue:[rdb.HTTPHeaders objectForKey:header] forHTTPHeaderField:header];
//    }
//    return urlRequest;
//}

@end
