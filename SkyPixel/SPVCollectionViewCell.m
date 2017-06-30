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
    
    RAC(self.typeContainerView, hidden) = [[RACObserve(self, viewModel)
                                   takeUntil:[self rac_prepareForReuseSignal]]
                                  map:^id(NSDictionary *value) {
                                      BOOL isPano = [[value objectForKey:@"is_pano"] boolValue];
                                      BOOL is360 = [[value objectForKey:@"is_360"] boolValue];
                                      NSString *type = [value objectForKey:@"type"];
                                      return [NSNumber numberWithBool:!isPano && !is360 && ![type isEqualToString:@"video"]];
                                  }];
    
    RAC(self.playButton, hidden) = [[RACObserve(self, viewModel)
                                            takeUntil:[self rac_prepareForReuseSignal]]
                                           map:^id(NSDictionary *value) {
                                               NSString *type = [value objectForKey:@"type"];
                                               return [NSNumber numberWithBool:![type isEqualToString:@"video"]];
                                           }];
    
    RAC(self.typeLabel, text) = [[RACObserve(self, viewModel)
                                            takeUntil:[self rac_prepareForReuseSignal]]
                                           map:^id(NSDictionary *value) {
                                               BOOL isPano = [[value objectForKey:@"is_pano"] boolValue];
                                               BOOL is360 = [[value objectForKey:@"is_360"] boolValue];
                                               NSString *type = [value objectForKey:@"type"];
                                               if([type isEqualToString:@"video"]) {
                                                   NSString *duration = [value objectForKey:@"duration"];
                                                   return duration == nil ? @"" : duration;
                                               } else if(isPano) {
                                                   return @"Pano";
                                               } else if(is360) {
                                                   return @"360°";
                                               } else {
                                                   return @"";
                                               }
                                           }];

    id value = [_viewModel objectForKey:@"image"];
    self.imageView.image = [UIImage imageNamed:@"photo"];
    self.imageView.contentMode = UIViewContentModeCenter;
    if([value respondsToSelector:@selector(stringByAppendingString:)]) {
        NSString *imagePath = [value stringByAppendingString:@"@!670x382"];        
        [[[self loadCoverWithURLString:imagePath] deliverOnMainThread] subscribeNext:^(UIImage *image) {
            self.imageView.image = image;
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }];
    } else {
        NSLog(@"image not loaded");
    }
    
    RAC(self.titleLabel, text) = [[RACObserve(self, viewModel)
                                   takeUntil:[self rac_prepareForReuseSignal]]
                                  map:^id(NSDictionary *value) {
        NSString *title = [value objectForKey:@"title"];
        if([title isKindOfClass:[NSString class]] || [title length] == 0) {
            return title;
        } else {
            return @"";
        }
    }];
    
    RAC(self.favoriteLabel, text) = [[RACObserve(self, viewModel)
                                   takeUntil:[self rac_prepareForReuseSignal]]
                                  map:^id(NSDictionary *value) {
                                      NSNumber *favoriteCount = [value objectForKey:@"favorites_count"];
                                      if([favoriteCount isKindOfClass:[NSNumber class]]) {
                                          return [NSString stringWithFormat:@"%ld", [favoriteCount integerValue]];
                                      } else {
                                          return @"";
                                      }
                                  }];
    
    RAC(self.likeLabel, text) = [[RACObserve(self, viewModel)
                                   takeUntil:[self rac_prepareForReuseSignal]]
                                  map:^id(NSDictionary *value) {
                                      NSNumber *count = [value objectForKey:@"likes_count"];
                                      if([count isKindOfClass:[NSNumber class]]) {
                                          return [NSString stringWithFormat:@"%ld", [count integerValue]];
                                      } else {
                                          return @"";
                                      }
                                  }];
    
    RAC(self.watchLabel, text) = [[RACObserve(self, viewModel)
                                   takeUntil:[self rac_prepareForReuseSignal]]
                                  map:^id(NSDictionary *value) {
                                      NSNumber *count = [value objectForKey:@"views_count"];
                                      if([count isKindOfClass:[NSNumber class]]) {
                                          return [NSString stringWithFormat:@"%ld", [count integerValue]];
                                      } else {
                                          return @"";
                                      }
                                  }];
}

-(RACSignal *) loadCoverWithURLString:(NSString *) urlString {
    RACScheduler *scheduler = [RACScheduler
                               schedulerWithPriority:RACSchedulerPriorityBackground];
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSData *data = nil;
        NSString *fileName = [urlString lastPathComponent];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:fileName];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            data = [NSData dataWithContentsOfFile:path];
        }
        
        if(!data) {
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            if(data) {
                [data writeToFile:path atomically:YES];
            }
        }

        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler];
}
@end
