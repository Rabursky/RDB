//
//  RDBImage.m
//  Bekon
//
//  Created by Marcin Raburski on 12.03.2014.
//  Copyright (c) 2014 Marcin Raburski. All rights reserved.
//

#import "RDBImage.h"
#import "RDBCache.h"

@interface RDBImage ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSMutableArray *imageBlocks;
@property (nonatomic, strong) NSError *error;

@end

@implementation RDBImage

+ (instancetype)objectWithJSONValue:(id)value {
    if (value && ![value isEqual:[NSNull null]]) {
        RDBImage *image = [RDBImage new];
        image.url = value;
        image.cacheTime = 60*60*24*7;
        return image;
    }
    return nil;
}

- (id)JSONValue {
    return self.url;
}

- (void)setUrl:(NSString *)url {
    _url = url;
    self.image = nil;
}

- (id)initWithImage:(UIImage *)image {
    return [self initWithImage:image clipToRound:NO];
}

- (id)initWithImage:(UIImage *)image clipToRound:(BOOL)clip {
    if (self = [super init]) {
        self.image = image;
        self.clipToRound = clip;
        if (clip) {
            [self clipToRoundExec];
        }
    }
    return self;
}


- (void)imageWithCompletionBlock:(RDBImageBlock)imageBlock {
    if (self.image) {
        imageBlock(self.image, nil);
    } else {
        @synchronized(self) {
            UIImage *cachedImage = [[RDBCache sharedCache] objectForKey:self.url];
            if (cachedImage) {
                self.image = cachedImage;
                imageBlock(self.image, self.error);
                return;
            }
            if (self.imageBlocks) {
                [self.imageBlocks addObject:imageBlock];
            } else {
                [[RDB sharedDB] retainNetworkActivity];
                self.imageBlocks = [[NSMutableArray alloc] initWithObjects:imageBlock, nil];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.url]]];
                
                AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
                requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id image) {
                    dispatch_queue_t imagequeue = dispatch_queue_create("com.rzeczy.Coinality.RDBImage", NULL);
                    dispatch_async(imagequeue, ^{
                        if (!image) {
                            self.image = [UIImage new];
                            for (RDBImageBlock completion in self.imageBlocks) {
                                void (^block)(UIImage* image, NSError* error) = completion;
                                block(self.image, [NSError errorWithDomain:@"Unknown" code:100 userInfo:nil]);
                            }
                        } else {
                            
                            self.image = image;
                            if (self.clipToRound) {
                                [self clipToRoundExec];
                            }
                            
                            for (RDBImageBlock completion in self.imageBlocks) {
                                void (^block)(UIImage* image, NSError* error) = completion;
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    block(self.image, nil);
                                });
                            }
                            dispatch_queue_t queue = dispatch_queue_create("com.rzeczy.Coinality.cache", NULL);
                            dispatch_async(queue, ^{
                                [[RDBCache sharedCache] setObject:self.image forKey:self.url withCacheTime:self.cacheTime];
                            });
                        }
                        self.imageBlocks = nil;
                        [[RDB sharedDB] releaseNetworkActivity];
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    self.image = [UIImage new];
                    self.error = [NSError errorWithDomain:@"Unknown" code:100 userInfo:nil];
                    for (RDBImageBlock completion in self.imageBlocks) {
                        void (^block)(UIImage* image, NSError* error) = completion;
                        block(self.image, self.error);
                    }
                    self.imageBlocks = nil;
                    [[RDB sharedDB] releaseNetworkActivity];
                }];
                [requestOperation start];
            }
        }
    }
}

- (void)clipToRoundExec {
    CGFloat lowerBound = MIN(self.image.size.width, self.image.size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(lowerBound, lowerBound), NO, 2.0);
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor clearColor].CGColor);
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, lowerBound, lowerBound)
                                cornerRadius:lowerBound / 2.0] addClip];
    // Draw your image
    if (self.image.size.width < self.image.size.height) {
        [self.image drawInRect:CGRectMake(0, - (self.image.size.height - self.image.size.width) / 2., self.image.size.width, self.image.size.height)];
    } else {
        [self.image drawInRect:CGRectMake(- (self.image.size.width - self.image.size.height) / 2., 0, self.image.size.width, self.image.size.height)];
    }
    
    
    // Get the image, here setting the UIImageView image
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
}

@end
