//
//  VideoPlayerViewController.m
//  LearningEnglishByVOA
//
//  Created by xiangwei wang on 2017/05/22.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "VideoPlayerViewController.h"
//#import <Masonry/Masonry.h>
#import <MediaPlayer/MediaPlayer.h>
#import <ReactiveObjc/ReactiveObjc.h>
#import "VideoViewModel.h"


@interface VideoPlayerViewController () {
    VideoViewModel *_viewModel;
    VMediaPlayer       *_player;
}
@property(nonatomic, weak) IBOutlet UIView *placeHolderView;
@property(nonatomic, weak) IBOutlet UISlider *slider;
@property(nonatomic, weak) IBOutlet UIButton *playButton;
@property(nonatomic, weak) IBOutlet UIButton *stopButton;
@property(nonatomic, weak) IBOutlet UIButton *closeButton;
@property(nonatomic, weak) IBOutlet UILabel *playTimeLabel;
@property(nonatomic, weak) IBOutlet UILabel *remainTimeLabel;
@property (nonatomic, assign) IBOutlet UIView  	*carrier;

@property(nonatomic, assign) BOOL touchBegan;

@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.slider setThumbImage:[UIImage imageNamed:@"slider-thumb"] forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:[[UIImage imageNamed:@"slider-left"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];

    self.playButton.hidden = YES;
    self.stopButton.hidden = YES;
    
    if (!_player) {
        _player = [VMediaPlayer sharedInstance];
        [_player setupPlayerWithCarrierView:self.view withDelegate:self];
        [self setupObservers];
    }
}

- (void)dealloc {
    [self unSetupObservers];
    [_player unSetupPlayer];
}

- (void)setupObservers {
    NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
    [def addObserver:self
            selector:@selector(applicationDidEnterForeground:)
                name:UIApplicationDidBecomeActiveNotification
              object:[UIApplication sharedApplication]];
    [def addObserver:self
            selector:@selector(applicationDidEnterBackground:)
                name:UIApplicationWillResignActiveNotification
              object:[UIApplication sharedApplication]];
}

- (void)unSetupObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterForeground:(NSNotification *)notification
{
    [_player setVideoShown:YES];
    if (![_player isPlaying]) {
        [_player start];
//        [self.startPause setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if ([_player isPlaying]) {
        [_player pause];
        [_player setVideoShown:NO];
    }
}

-(BOOL) prefersStatusBarHidden {
    return YES;
}

-(void) play:(NSString *) videoPath {
    if(!_viewModel) {
        _viewModel = [[VideoViewModel alloc] init];
        [[_viewModel.videoURLSignal deliverOnMainThread] subscribeNext:^(NSArray* videoDefinitions) {
            NSUInteger playingIndex = 0;
            if([videoDefinitions count] == 3) {
                playingIndex = 1;
            } else if([videoDefinitions count] > 3) {
                playingIndex = 2;
            }
            _viewModel.playingIndex = playingIndex;
            [self playSelectedVideo];
        }];
    }
    _viewModel.URL = videoPath;
 
    [_player setDataSource:[NSURL URLWithString:_viewModel.URL]];
    [_player prepareAsync];
}
#pragma mark -
-(void) hideControls {
    [UIView animateWithDuration:1 animations:^{
        self.placeHolderView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

-(void) playSelectedVideo {
    self.playTimeLabel.text = self.remainTimeLabel.text = @"00:00";
    NSDictionary *dict = [_viewModel.videoDefinitions objectAtIndex:_viewModel.playingIndex];

}

-(void) updatePlauAndPauseButton:(float) rate {
    if(rate == 0) {
        self.playButton.hidden = NO;
        self.stopButton.hidden = YES;
    } else {
        self.playButton.hidden = YES;
        self.stopButton.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan");
    [self showControls];
}

-(void) showControls {
    self.placeHolderView.alpha = 1;
    [VideoPlayerViewController cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideControls) withObject:nil afterDelay:3.0];
}
#pragma mark -
-(IBAction)sliderValueChanged:(id)sender {
//    CGFloat seekTime = self.slider.value;
//    CMTimeScale timeScale = self.player.currentItem.asset.duration.timescale;
//    [self.player pause];
//    [self.player seekToTime:CMTimeMakeWithSeconds(seekTime, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//    [self.player play];
    
    [self showControls];
}

-(IBAction)playButtonToched:(id)sender {
//    [_player play];
    
    [self showControls];
}

-(IBAction)pauseButtonToched:(id)sender {
    [_player pause];
    
    [self showControls];
}

-(IBAction)closeButtonToched:(id)sender {
    [_player pause];
    //self.view.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"play" object:nil];
}

-(IBAction)sliderTouchDown:(id)sender {
    _touchBegan = YES;
    NSLog(@"touchDown");
    
    [VideoPlayerViewController cancelPreviousPerformRequestsWithTarget:self];
}

-(IBAction)sliderTouchUp:(id)sender {
    _touchBegan = NO;
    NSLog(@"touchUp");
    
    [self performSelector:@selector(hideControls) withObject:nil afterDelay:3.0];
}

#pragma mark - VMediaPlayerDelegate Implement

#pragma mark VMediaPlayerDelegate Implement / Required

- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    //	[player setVideoFillMode:VMVideoFillMode100];
    
//    mDuration = [player getDuration];
    [_player start];
    
//    [self setBtnEnableStatus:YES];
//    [self stopActivity];
//    mSyncSeekTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/3
//                                                      target:self
//                                                    selector:@selector(syncUIStatus)
//                                                    userInfo:nil
//                                                     repeats:YES];
}

- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
    NSLog(@"playbackComplete");
//    [self goBackButtonAction:nil];
}

- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
    NSLog(@"NAL 1RRE &&&& VMediaPlayer Error: %@", arg);
//    [self stopActivity];
//    //	[self showVideoLoadingError];
//    [self setBtnEnableStatus:YES];
}

#pragma mark VMediaPlayerDelegate Implement / Optional

- (void)mediaPlayer:(VMediaPlayer *)player setupManagerPreference:(id)arg
{
    _player.decodingSchemeHint = VMDecodingSchemeSoftware;
    _player.autoSwitchDecodingScheme = NO;
}

- (void)mediaPlayer:(VMediaPlayer *)player setupPlayerPreference:(id)arg
{
    // Set buffer size, default is 1024KB(1*1024*1024).
    //	[player setBufferSize:256*1024];
    [_player setBufferSize:512*1024];
    //	[player setAdaptiveStream:YES];
    
    [_player setVideoQuality:VMVideoQualityHigh];
    
    _player.useCache = YES;
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    [_player setCacheDirectory:cachePath];
}

- (void)mediaPlayer:(VMediaPlayer *)player seekComplete:(id)arg
{
}

- (void)mediaPlayer:(VMediaPlayer *)player notSeekable:(id)arg
{
//    self.progressDragging = NO;
    NSLog(@"NAL 1HBT &&&&&&&&&&&&&&&&.......&&&&&&&&&&&&&&&&&");
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg
{
//    self.progressDragging = YES;
    NSLog(@"NAL 2HBT &&&&&&&&&&&&&&&&.......&&&&&&&&&&&&&&&&&");
//    if (![Utilities isLocalMedia:self.videoURL]) {
//        [player pause];
//        [self.startPause setTitle:@"Start" forState:UIControlStateNormal];
//        [self startActivityWithMsg:@"Buffering... 0%"];
//    }
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingUpdate:(id)arg
{
//    if (!self.bubbleMsgLbl.hidden) {
//        self.bubbleMsgLbl.text = [NSString stringWithFormat:@"Buffering... %d%%",
//                                  [((NSNumber *)arg) intValue]];
//    }
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg
{
//    if (![Utilities isLocalMedia:self.videoURL]) {
        [_player start];
//        [self.startPause setTitle:@"Pause" forState:UIControlStateNormal];
//        [self stopActivity];
//    }
//    self.progressDragging = NO;
    NSLog(@"NAL 3HBT &&&&&&&&&&&&&&&&.......&&&&&&&&&&&&&&&&&");
}

- (void)mediaPlayer:(VMediaPlayer *)player downloadRate:(id)arg
{
//    if (![Utilities isLocalMedia:self.videoURL]) {
//        self.downloadRate.text = [NSString stringWithFormat:@"%dKB/s", [arg intValue]];
//    } else {
//        self.downloadRate.text = nil;
//    }
}

- (void)mediaPlayer:(VMediaPlayer *)player videoTrackLagging:(id)arg
{
    //	NSLog(@"NAL 1BGR video lagging....");
}

#pragma mark VMediaPlayerDelegate Implement / Cache

- (void)mediaPlayer:(VMediaPlayer *)player cacheNotAvailable:(id)arg
{
    NSLog(@"NAL .... media can't cache.");
//    self.progressSld.segments = nil;
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheStart:(id)arg
{
    NSLog(@"NAL 1GFC .... media caches index : %@", arg);
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheUpdate:(id)arg
{
    NSArray *segs = (NSArray *)arg;
    //	NSLog(@"NAL .... media cacheUpdate, %d, %@", segs.count, segs);
//    if (mDuration > 0) {
//        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
//        for (int i = 0; i < segs.count; i++) {
//            float val = (float)[segs[i] longLongValue] / mDuration;
//            [arr addObject:[NSNumber numberWithFloat:val]];
//        }
//        self.progressSld.segments = arr;
//    }
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheSpeed:(id)arg
{
    //	NSLog(@"NAL .... media cacheSpeed: %dKB/s", [(NSNumber *)arg intValue]);
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheComplete:(id)arg
{
    NSLog(@"NAL .... media cacheComplete");
//    self.progressSld.segments = @[@(0.0), @(1.0)];
}
@end
