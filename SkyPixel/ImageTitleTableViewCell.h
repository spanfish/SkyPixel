//
//  ImageTitleTableViewCell.h
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>

@interface ImageTitleTableViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *dateLabel;

-(void) configureCellWithModel:(NSDictionary *) model;
@end


@interface CommentTableViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *dateLabel;
@property(nonatomic, weak) IBOutlet UILabel *commentLabel;

-(void) configureCellWithModel:(NSDictionary *) model;
@end

@interface ResourceTableViewCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

-(void) configureCellWithModel:(NSArray *) model;

@property(nonatomic, strong) RACSubject *touchSignal;
@end
