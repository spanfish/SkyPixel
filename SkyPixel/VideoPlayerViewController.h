//
//  VideoPlayerViewController.h
//  LearningEnglishByVOA
//
//  Created by xiangwei wang on 2017/05/22.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Vitamio.h"

@interface VideoPlayerViewController : UIViewController<VMediaPlayerDelegate>

-(void) play:(NSString *) videoPath;


@end
