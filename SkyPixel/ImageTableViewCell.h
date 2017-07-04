//
//  ImageTableViewCell.h
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPVImageView.h"

@interface ImageTableViewCell : UITableViewCell {
    
}
@property(nonatomic, weak) IBOutlet SPVImageView *coverImageView;
@property(nonatomic, weak) IBOutlet UILabel *equipLabel;
@property(nonatomic, weak) IBOutlet UILabel *locationLabel;
@property(nonatomic, weak) IBOutlet UILabel *shutterLabel;
@property(nonatomic, weak) IBOutlet UILabel *focusLabel;
@property(nonatomic, weak) IBOutlet UIButton *playButton;
@property(nonatomic, weak) IBOutlet UIButton *magnifyButton;

-(void) configureCellWithModel:(NSDictionary *) model;
@end
