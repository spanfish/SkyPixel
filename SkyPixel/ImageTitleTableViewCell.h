//
//  ImageTitleTableViewCell.h
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTitleTableViewCell : UITableViewCell

@property(nonatomic, strong) NSDictionary *model;

@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *dateLabel;
@end


@interface CommentTableViewCell : UITableViewCell

@property(nonatomic, strong) NSDictionary *model;

@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *dateLabel;
@property(nonatomic, weak) IBOutlet UILabel *commentLabel;
@end
