//
//  LoadingView.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/07/05.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) awakeFromNib {
    [super awakeFromNib];
    self.loadingImageView.animationImages = @[
                                                      [UIImage imageNamed:@"more"],
                                                      [UIImage imageNamed:@"more_loading_1"],
                                                      [UIImage imageNamed:@"more_loading_2"],
                                                      [UIImage imageNamed:@"more_loading_3"]
                                                      ];
    self.loadingImageView.animationDuration = 1.2;
}

@end
