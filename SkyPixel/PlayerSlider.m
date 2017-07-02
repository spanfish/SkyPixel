//
//  PlayerSlider.m
//  LearningEnglishByVOA
//
//  Created by Xiangwei Wang on 2017/05/22.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "PlayerSlider.h"

@implementation PlayerSlider


- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(0, bounds.size.height - 16, bounds.size.width, 16);
}
@end
