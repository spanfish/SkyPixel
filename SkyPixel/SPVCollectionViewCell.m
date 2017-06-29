//
//  SPVCollectionViewCell.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/29.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "SPVCollectionViewCell.h"
#import <ReactiveCocoa.h>

@implementation SPVCollectionViewCell

-(void) setViewModel:(NSDictionary *) viewModel {
    _viewModel = viewModel;
    
    //NSString *type = [value objectForKey:@"type"];
    //BOOL isPano = [[value objectForKey:@"is_pano"] boolValue];
    //BOOL is360 = [[value objectForKey:@"is_360"] boolValue];
    //self.imageView.image = nil;
    id value = [_viewModel objectForKey:@"image"];
    
    if([value respondsToSelector:@selector(stringByAppendingString:)]) {
        NSString *imagePath = [value stringByAppendingString:@"@!670x382"];        
        [[[self loadCoverWithURLString:imagePath] deliverOnMainThread] subscribeNext:^(UIImage *image) {
            self.imageView.image = image;
            //NSLog(@"image loaded: %@", imagePath);
        }];
    } else {
        //NSLog(@"****_viewModel****%@", _viewModel);
        NSLog(@"image not loaded");
    }
}

-(RACSignal *) loadCoverWithURLString:(NSString *) urlString {
    RACScheduler *scheduler = [RACScheduler
                               schedulerWithPriority:RACSchedulerPriorityBackground];
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler];
}
@end
