//
//  SPVCollectionViewCell.h
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/29.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPVCollectionViewCell : UICollectionViewCell

@property(nonatomic, weak) IBOutlet UIImageView *imageView;
@property(nonatomic, strong) NSDictionary *viewModel;

@end
