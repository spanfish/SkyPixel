//
//  ImageTitleTableViewCell.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "ImageTitleTableViewCell.h"
#import <ReactiveCocoa.h>

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
