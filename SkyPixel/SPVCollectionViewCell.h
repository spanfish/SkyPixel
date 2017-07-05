//
//  SPVCollectionViewCell.h
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/29.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPVImageView.h"
#import <ReactiveCocoa.h>
#import "UIImageView+AsynLoad.h"

@interface SPVCollectionViewCell : UICollectionViewCell

@property(nonatomic, weak) IBOutlet UIImageView *imageView;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *favoriteLabel;
@property(nonatomic, weak) IBOutlet UILabel *likeLabel;
@property(nonatomic, weak) IBOutlet UILabel *watchLabel;
@property(nonatomic, weak) IBOutlet UILabel *typeLabel;
@property(nonatomic, weak) IBOutlet UIView *typeContainerView;
@property(nonatomic, weak) IBOutlet UIButton *playButton;

@property(nonatomic, strong) NSDictionary *viewModel;
@property(nonatomic, strong) RACCommand *playCommand;

@end


@interface SPVAdCell : UICollectionViewCell

@end
