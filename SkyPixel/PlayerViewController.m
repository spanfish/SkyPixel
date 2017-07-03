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
}

@property(nonatomic, assign) long mDuration;
@property(nonatomic, assign) long mCurPostion;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mMPayer = [VMediaPlayer sharedInstance];
    
    self.closeButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self exitPlayer];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"play" object:nil];
        return [RACSignal empty];
    }];
    
    self.definitionsButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.alpha = 1;
        }];
        
        return [RACSignal empty];
    }];
    
    RAC(self.curPosLabel, text) = [RACObserve(self, mCurPostion) map:^id(NSNumber *value) {
        return timeToHumanString([value longValue]);
    }];
    
    RAC(self.durationLabel, text) = [RACObserve(self, mDuration) map:^id(NSNumber *value) {
        return timeToHumanString([value longValue]);
    }];
    
    RAC(self.curPosSlider, maximumValue) = RACObserve(self, mDuration);
    
    RAC(self.curPosSlider, value) = [RACObserve(self, mCurPostion) filter:^BOOL(id value) {
        return !_tracking;
    }];
    
    self.mCurPostion = 0;
    self.mDuration = 0;
    self.tableView.alpha = 0;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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

-(void) play:(NSString *) URL {
    self.viewModel = [[VideoViewModel alloc] initWithModel:URL];
    
    @weakify(self);
    [[[self.viewModel.videoDefinitionsSignal deliverOnMainThread]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(NSArray *definitions) {
         @strongify(self);
         if([definitions count] > 0) {
             NSDictionary *video = [definitions firstObject];
             
             [self.mMPayer setupPlayerWithCarrierView:self.view withDelegate:self];
             [self.mMPayer setDataSource:[NSURL URLWithString:[video objectForKey:@"src"]] header:nil];
             [self.mMPayer prepareAsync];
         }
         [self.tableView reloadData];
     }];
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
- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    self.mDuration = [player getDuration];
    [self.mMPayer start];
    
    @weakify(self);
    [[[RACSignal interval:0.5 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.closeButton.rac_command.executionSignals] subscribeNext:^(NSDate *date) {
        @strongify(self);
        self.mCurPostion  = [self.mMPayer getCurrentPosition];
    }];
}
// 当'该音视频播放完毕'时, 该协议方法被调用, 我们可以在此作一些播放器善后
// 操作, 如: 重置播放器, 准备播放下一个音视频等
- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
    [self.mMPayer reset];
}
// 如果播放由于某某原因发生了错误, 导致无法正常播放, 该协议方法被调用, 参
// 数 arg 包含了错误原因.
- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
    NSLog(@"NAL 1RRE &&&& VMediaPlayer Error: %@", arg);
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
@end
