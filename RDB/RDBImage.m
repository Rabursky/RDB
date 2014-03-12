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

@end

@implementation RDBImage

+ (instancetype)objectWithJSONValue:(id)value {
    RDBImage *image = [RDBImage new];
    image.url = value;
    image.cacheTime = 60*60*24*7;
    return image;
}

- (id)JSONValue {
    return self.url;
}

- (void)setUrl:(NSString *)url {
    _url = url;
    self.image = nil;
}

- (void)imageWithCompletionBlock:(RDBImageBlock)imageBlock {
    if (self.image) {
        imageBlock(self.image, nil);
    } else {
        @synchronized(self) {
            UIImage *cachedImage = [[RDBCache sharedCache] objectForKey:self.url];
            if (cachedImage) {
                self.image = cachedImage;
                imageBlock(self.image, nil);
                return;
            }
            if (self.imageBlocks) {
                [self.imageBlocks addObject:imageBlock];
            } else {
                [[RDB sharedDB] retainNetworkActivity];
                self.imageBlocks = [[NSMutableArray alloc] initWithObjects:imageBlock, nil];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.url]]];
                AFImageRequestOperation *reqOperation = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest success:^(UIImage *image) {
                    if (!image) {
                        for (RDBImageBlock completion in self.imageBlocks) {
                            void (^block)(UIImage* image, NSError* error) = completion;
                            block(self.image, [NSError errorWithDomain:@"Unknown" code:100 userInfo:nil]);
                        }
                    } else {
                        
                        if (self.clipToRound) {
                            CGFloat lowerBound = MIN(image.size.width, image.size.height);
                            UIGraphicsBeginImageContextWithOptions(CGSizeMake(lowerBound, lowerBound), NO, 1.0);
                            
                            CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor clearColor].CGColor);
                            // Add a clip before drawing anything, in the shape of an rounded rect
                            [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, lowerBound, lowerBound)
                                                        cornerRadius:lowerBound / 2.0] addClip];
                            // Draw your image
                            if (image.size.width < image.size.height) {
                                [image drawInRect:CGRectMake(0, - (image.size.height - image.size.width) / 2., image.size.width, image.size.height)];
                            } else {
                                [image drawInRect:CGRectMake(- (image.size.width - image.size.height) / 2., 0, image.size.width, image.size.height)];
                            }
                            
                            
                            // Get the image, here setting the UIImageView image
                            self.image = UIGraphicsGetImageFromCurrentImageContext();
                            
                            // Lets forget about that we were drawing
                            UIGraphicsEndImageContext();
                        } else {
                            self.image = image;
                        }
                        
                        
                        for (RDBImageBlock completion in self.imageBlocks) {
                            void (^block)(UIImage* image, NSError* error) = completion;
                            block(self.image, nil);
                        }
                        
                        [[RDBCache sharedCache] setObject:self.image forKey:self.url withCacheTime:self.cacheTime];
                    }
                    self.imageBlocks = nil;
                    [[RDB sharedDB] releaseNetworkActivity];
                }];
                [reqOperation start];
            }
        }
    }
}

@end
