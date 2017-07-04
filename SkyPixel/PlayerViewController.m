//
//  PlayerViewController.m
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/07/03.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "PlayerViewController.h"
#import <ReactiveCocoa.h>

@interface PlayerViewController ()
{
    BOOL _tracking;
    RACDisposable *_touchDelaySignal;
    BOOL _controlsVisible;
}

@property(nonatomic, assign) long mDuration;
@property(nonatomic, assign) long mCurPostion;
@property(nonatomic, strong) RACSubject *loadingSignal;
@property(nonatomic, strong) RACSubject *playingSignal;

@end


static NSString* timeToHumanString(unsigned long ms)
{
    unsigned long seconds, h, m, s;
    char buff[128] = { 0 };
    NSString *nsRet = nil;
    
    seconds = ms / 1000;
    h = seconds / 3600;
    m = (seconds - h * 3600) / 60;
    s = seconds - h * 3600 - m * 60;
    snprintf(buff, sizeof(buff), "%02ld:%02ld:%02ld", h, m, s);
    nsRet = [[NSString alloc] initWithCString:buff
                                     encoding:NSUTF8StringEncoding];
    
    return nsRet;
}

@implementation PlayerViewController
-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
    }
    return self;
}

-(instancetype) initWithURL:(NSString *) url {
    self = [super init];
    if(self) {
        self.mMPayer = [VMediaPlayer sharedInstance];
        self.viewModel = [[VideoViewModel alloc] initWithModel:url];
        self.mCurPostion = 0;
        self.mDuration = 0;
        self.tableView.alpha = 0;
        self.playingSignal = [[RACSubject subject] setNameWithFormat:@"playingSignal"];
        self.loadingSignal = [[RACSubject subject] setNameWithFormat:@"loadingSignal"];
        _controlsVisible = YES;
    }
    return self;
}

-(void) bindSingals {
    //indicator view
    @weakify(self);
    [[self.loadingSignal deliverOnMainThread] subscribeNext:^(NSNumber *loadingStatus) {
        @strongify(self);
        if([loadingStatus boolValue]) {
            if(![self.indicatorView isAnimating]) {
                [self.indicatorView startAnimating];
            }
        } else {
            [self.indicatorView stopAnimating];
        }
    }];
    
    //close action
    self.closeButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self exitPlayer];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"play" object:nil];
        return [RACSignal empty];
    }];

    //resolution action
    self.definitionsButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.alpha = 1;
        }];
        
        return [RACSignal empty];
    }];
    
    //show current position
    RAC(self.curPosLabel, text) = [[RACObserve(self, mCurPostion) filter:^BOOL(NSNumber *value) {
        NSLog(@"cur pos:%ld", [value longValue]);
        return [value longValue] >= 0 && [value longValue] <= self.mDuration;
    }] map:^id(NSNumber *value) {
        NSString *pos = timeToHumanString([value longValue]);
        NSLog(@"pos:%@", pos);
        return pos;
    }];
    
    //show duration
    RAC(self.durationLabel, text) = [RACObserve(self, mDuration) map:^id(NSNumber *value) {
        return timeToHumanString([value longValue]);
    }];
    
    //current position track bar
    RAC(self.curPosSlider, maximumValue) = RACObserve(self, mDuration);
    RAC(self.curPosSlider, value) = [RACObserve(self, mCurPostion) filter:^BOOL(id value) {
        return !_tracking;
    }];
    
    RACSignal *signal = [RACSignal combineLatest:@[self.loadingSignal, self.playingSignal]];
    [[signal deliverOnMainThread] subscribeNext:^(RACTuple *values) {
        @strongify(self);
        BOOL loading = [[values first] boolValue];
        BOOL playing = [[values second] boolValue];
        if(loading) {
            self.playButton.hidden = YES;
            self.pauseButton.hidden = YES;
            self.controlView.hidden = YES;
        } else {
            self.controlView.hidden = NO;
            self.playButton.hidden = playing;
            self.pauseButton.hidden = !playing;
        }
    }];
   
    self.pauseButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.mMPayer pause];
        return [RACSignal empty];
    }];
    
    self.playButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.mMPayer start];
        return [RACSignal empty];
    }];
    
    [[RACObserve(self.viewModel, playingIndex) deliverOnMainThread] subscribeNext:^(NSNumber *playingIndex) {
        NSInteger i = [playingIndex integerValue];
        if(i >= 0 && i < [self.viewModel.videoDefinitions count]) {
            NSDictionary *video = [self.viewModel.videoDefinitions objectAtIndex:i];
            [self play:[video objectForKey:@"src"]];
            [self.definitionsButton setTitle:[video objectForKey:@"text"] forState:UIControlStateNormal];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.alpha = 0;
    
    [self bindSingals];
    
    [self.loadingSignal sendNext:@YES];
    [self.playingSignal sendNext:@NO];
    
    @weakify(self);
    [[[self.viewModel.videoDefinitionsSignal deliverOnMainThread]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(NSArray *definitions) {
         @strongify(self);
         
         if([definitions count] > 0) {
             self.viewModel.playingIndex = 0;
         }
         [self.tableView reloadData];
     }];
}

-(void) play:(NSString *)URL {
    [self.mMPayer reset];

    [self.mMPayer setupPlayerWithCarrierView:self.view withDelegate:self];
    [self.mMPayer setDataSource:[NSURL URLWithString:URL] header:nil];
    [self.mMPayer prepareAsync];
    
    self.allControlView.alpha = _controlsVisible ? 1 : 0;
    [self cancelDelayedSignal];
    [self createDelayedSignal];
}

-(void) dealloc {
    [self exitPlayer];
}

-(BOOL) prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) exitPlayer {
    if(self.mMPayer) {
        if(self.mMPayer.isPlaying) {
            [self.mMPayer pause];
            [self.mMPayer reset];
        }
        [self.mMPayer unSetupPlayer];
    }
    self.mMPayer = nil;
}
#pragma mark - player delegate
- (void)mediaPlayer:(VMediaPlayer *)player info:(id)arg {
    NSLog(@"mediaPlayer info:%@", arg);
}

- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg {
    self.mDuration = [player getDuration];
    [self.mMPayer start];

    [self.loadingSignal sendNext:@NO];
    self.messageLabel.text = @"";

    @weakify(self);
    [[[RACSignal interval:0.2 onScheduler:[RACScheduler mainThreadScheduler]]
      takeUntil:self.closeButton.rac_command.executionSignals]
     subscribeNext:^(NSDate *date) {
         @strongify(self);
         self.mCurPostion  = [self.mMPayer getCurrentPosition];
         [self.playingSignal sendNext: @([self.mMPayer isPlaying])];
    }];
}
// 当'该音视频播放完毕'时, 该协议方法被调用, 我们可以在此作一些播放器善后
// 操作, 如: 重置播放器, 准备播放下一个音视频等
- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg {
    [self.mMPayer reset];
    [self.playingSignal sendNext:@NO];
}

// 如果播放由于某某原因发生了错误, 导致无法正常播放, 该协议方法被调用, 参
// 数 arg 包含了错误原因.
- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg {
    NSLog(@"NAL 1RRE &&&& VMediaPlayer Error: %@", arg);
    [self.playingSignal sendNext:@NO];
    self.messageLabel.text = NSLocalizedString(@"unable to play the video", nil);
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel.videoDefinitions count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    [self configureCell: cell atIndexPath:indexPath];
    return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor blackColor];
    cell.contentView.backgroundColor = [UIColor blackColor];
}

-(void) configureCell:(UITableViewCell*) cell atIndexPath:(NSIndexPath *) indexPath {
    NSDictionary *definition = [self.viewModel.videoDefinitions objectAtIndex:indexPath.row];
    cell.textLabel.text = [definition objectForKey:@"text"];
    cell.textLabel.textColor = [UIColor whiteColor];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.alpha = 0;
    self.viewModel.playingIndex = indexPath.row;
}
#pragma mark - UISlider
- (IBAction)curPosChanged:(id)sender {
}

- (IBAction)dragBegin:(id)sender {
    _tracking = YES;
}
- (IBAction)dragEnd:(id)sender {
    if(_tracking) {
        [_mMPayer seekTo:self.curPosSlider.value];
    }
    [self dragCancel:sender];
}
- (IBAction)dragCancel:(id)sender {
    _tracking = NO;
}

#pragma mark - Touches
-(void) cancelDelayedSignal {
    if(_touchDelaySignal) {
        [_touchDelaySignal dispose];
    }
    _touchDelaySignal = nil;
}

-(void) createDelayedSignal {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:nil];
        return nil;
    }];
    
    @weakify(self);
    _touchDelaySignal = [[[signal delay:3] deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        _controlsVisible = NO;
        [UIView animateWithDuration:1.5 animations:^{
            self.allControlView.alpha = 0;
        }];
    }];
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self cancelDelayedSignal];
    _controlsVisible = !_controlsVisible;
    self.allControlView.alpha = _controlsVisible ? 1 : 0;
    [self createDelayedSignal];
}

-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

-(void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}
@end
