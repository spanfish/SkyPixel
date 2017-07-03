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
#import "SPVImageView.h"

@interface ImageTitleTableViewCell()

@property(nonatomic, strong) NSDictionary *model;
@end

@implementation ImageTitleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) configureCellWithModel:(NSDictionary *) model {
    if(_model == model) {
        return;
    }
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

#pragma mark -
@interface CommentTableViewCell()

@property(nonatomic, strong) NSDictionary *model;
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

-(void) configureCellWithModel:(NSDictionary *)model {
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

#pragma mark -
@interface ResourceTableViewCell()

@property(nonatomic, strong) NSArray *model;
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

-(void) configureCellWithModel:(NSArray *)model {
    if(_model == model) {
        return;
    }
    _model = model;
    if(!_touchSignal) {
        _touchSignal = [RACSubject subject];
    }

    self.scrollView.contentSize = CGSizeMake(219 * [model count] + ([model count] + 1)* 10, 155);
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    NSInteger offsetX = 10;
    NSInteger i = 0;
    for (NSDictionary *r in _model) {
        SPVImageView *imageView = [[SPVImageView alloc] initWithFrame:CGRectMake(offsetX, 0, 219, 155)];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouched:)];
        [imageView addGestureRecognizer:recognizer];
        
        imageView.tag = i++;
        [self.scrollView addSubview:imageView];
//        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(offsetX);
//            make.top.mas_equalTo(0);
//            make.width.mas_equalTo(219);
//            make.height.mas_equalTo(155);
//        }];
        offsetX += 219;
        offsetX += 10;
        

        NSString *imagePath = [r objectForKey:@"image"];
        if([imagePath isKindOfClass:[NSString class]]) {
            imagePath = [imagePath stringByAppendingString:@"@!219x155"];
            imageView.imagePath = imagePath;
        }
    }
}

-(void) imageTouched:(UITapGestureRecognizer *) recognizer {
    NSInteger tag = recognizer.view.tag;
    if(tag >= 0 && tag < [_model count]) {
        NSDictionary *r = [_model objectAtIndex:tag];
        [self.touchSignal sendNext:r];
    }
}
@end
