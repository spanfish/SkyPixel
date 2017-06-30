//
//  ImageTableViewCell.h
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTableViewCell : UITableViewCell {
    
}
@property(nonatomic, weak) IBOutlet UIImageView *coverImageView;
@property(nonatomic, weak) IBOutlet UILabel *equipLabel;
@property(nonatomic, weak) IBOutlet UILabel *locationLabel;
@property(nonatomic, weak) IBOutlet UILabel *shutterLabel;
@property(nonatomic, weak) IBOutlet UILabel *focusLabel;

-(void) configureCellWithModel:(NSDictionary *) model;
@end
