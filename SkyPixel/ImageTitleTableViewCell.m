//
//  ImageTitleTableViewCell.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "ImageTitleTableViewCell.h"
#import <ReactiveCocoa.h>
#import <Masonry.h>
@implementation ImageTitleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setModel:(NSDictionary *)model {
    _model = model;
    
    self.titleLabel.text = @"";
    self.dateLabel.text = @"";
    
    RAC(self.titleLabel, text) = [[RACObserve(self, model)
                                   takeUntil:[self rac_prepareForReuseSignal]]
                                  map:^id(NSDictionary *value) {
                                      NSString *title = [value objectForKey:@"title"];
                                      
                                      if([title isKindOfClass:[NSString class]] && title != nil) {
                                          return title;
                                      } else {
                                          return @"";
                                      }
                                  }];
    
    RAC(self.dateLabel, text) = [[RACObserve(self, model)
                                   takeUntil:[self rac_prepareForReuseSignal]]
                                  map:^id(NSDictionary *value) {
                                      NSString *createdAt = [value objectForKey:@"created_at"];
                                      NSString *license = [value objectForKey:@"license"];
                                      
                                      if(![createdAt isKindOfClass:[NSString class]] || createdAt == nil) {
                                          createdAt = @"";
                                      }
                                      
                                      if(![license isKindOfClass:[NSString class]] || license == nil) {
                                          license = @"";
                                      }
                                      
                                      return [NSString stringWithFormat:@"%@ %@", createdAt, license];
                                  }];
}
@end

@implementation CommentTableViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) setModel:(NSDictionary *)model {
    if(_model == model) {
        return;
    }
    _model = model;
    
    self.nameLabel.text = @"";
    self.dateLabel.text = @"";
    self.commentLabel.text = @"";
    
    RAC(self.nameLabel, text) = [[RACObserve(self, model)
                                   takeUntil:[self rac_prepareForReuseSignal]]
                                  map:^id(NSDictionary *value) {
                                      NSString *name = @"";
                                      NSDictionary *dict = [value objectForKey:@"account"];
                                      if([dict isKindOfClass:[NSDictionary class]]) {
                                          name = [dict objectForKey:@"name"];
                                      }
                                      
                                      if([name isKindOfClass:[NSString class]] && name != nil) {
                                          return name;
                                      } else {
                                          return @"";
                                      }
                                  }];
    
    RAC(self.dateLabel, text) = [[RACObserve(self, model)
                                  takeUntil:[self rac_prepareForReuseSignal]]
                                 map:^id(NSDictionary *value) {
                                     NSString *createdAt = [value objectForKey:@"created_at"];
                                     
                                     if(![createdAt isKindOfClass:[NSString class]] || createdAt == nil) {
                                         createdAt = @"";
                                     }
                                     
                                     return createdAt;
                                 }];
    
    RAC(self.commentLabel, text) = [[RACObserve(self, model)
                                  takeUntil:[self rac_prepareForReuseSignal]]
                                 map:^id(NSDictionary *value) {
                                     NSString *content = [value objectForKey:@"content"];
                                     
                                     if(![content isKindOfClass:[NSString class]] || content == nil) {
                                         content = @"";
                                     }
                                     
                                     return content;
                                 }];
}
@end

@implementation ResourceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) setModel:(NSArray *)model {
//    if(_model == model) {
//        return;
//    }
    _model = model;
    self.scrollView.contentSize = CGSizeMake(219 * [model count] + ([model count] + 1)* 10, 155);
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    NSInteger offsetX = 10;
    for (NSDictionary *r in _model) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 0, 219, 155)];
        
        [self.scrollView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(offsetX);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(219);
            make.height.mas_equalTo(155);
        }];
        offsetX += 219;
        offsetX += 10;
        
        //image
        @weakify(imageView);
        NSString *imagePath = [r objectForKey:@"image"];
        if([imagePath isKindOfClass:[NSString class]]) {
            imagePath = [imagePath stringByAppendingString:@"@!219x155"];
            [[[[self loadImageWithURLString:imagePath]
               takeUntil:[imageView rac_willDeallocSignal]]
              deliverOnMainThread]
             subscribeNext:^(UIImage *image) {
                 @strongify(imageView);
                 imageView.image = image;
                 imageView.contentMode = UIViewContentModeScaleAspectFill;
             }];
        }
    }
}

-(RACSignal *) loadImageWithURLString:(NSString *) urlString {
    NSLog(@"urlString:%@", urlString);
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
