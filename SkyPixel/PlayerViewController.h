//
//  PlayerViewController.h
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/07/03.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vitamio.h"
#import "VideoViewModel.h"

@interface PlayerViewController : UIViewController<VMediaPlayerDelegate, UITableViewDelegate, UITableViewDataSource> {
    
}
@property(nonatomic, weak) IBOutlet UILabel *curPosLabel;
@property(nonatomic, weak) IBOutlet UILabel *durationLabel;
@property(nonatomic, weak) IBOutlet UISlider *curPosSlider;
@property(nonatomic, weak) IBOutlet UIButton *definitionsButton;
@property(nonatomic, weak) IBOutlet UIButton *playButton;
@property(nonatomic, weak) IBOutlet UIButton *pauseButton;
@property(nonatomic, weak) IBOutlet UIView *controlView;
@property(nonatomic, weak) IBOutlet UILabel *messageLabel;

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UIButton *closeButton;

@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;

@property(nonatomic, weak) IBOutlet UIView *allControlView;

@property(nonatomic, strong) VMediaPlayer *mMPayer;
@property(nonatomic, strong) VideoViewModel *viewModel;
//-(void) play:(NSString *) URL;

-(instancetype) initWithURL:(NSString *) URL;
@end
