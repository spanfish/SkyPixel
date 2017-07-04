//
//  SPVImageView.h
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/07/01.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>

@interface SPVImageView : UIImageView

@property(nonatomic, strong) NSString *imagePath;
@property(nonatomic, strong) RACSubject *imageLoadedSignal;
@end
