//
//  MainCollectionViewController.m
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/06/28.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "MainCollectionViewController.h"
#import "UIActivityIndicatorView+loading.h"
#import "SPVCollectionViewCell.h"
#import "ImageDetailViewController.h"
//#import <Masonry/Masonry.h>
#import "VideoPlayerViewController.h"
#import "AppDelegate.h"
#import <ReactiveObjc/ReactiveObjc.h>

#define DESCRIPTION_HEIGHT 50

@interface MainCollectionViewController () {
    VideoPlayerViewController *_videoPlayerController;
    UIWindow *_window;
}

@property (nonatomic, strong) UIImageView *indicatorView;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic) SPVCreationModel *viewModel;
@end

@implementation MainCollectionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"play" object:nil] map:^id(NSNotification *notification) {
        return [notification object];
    }] deliverOnMainThread] subscribeNext:^(NSString *url) {
        NSLog(@"video:%@", url);
        if(url) {
            if(!_window) {
                _videoPlayerController = [[VideoPlayerViewController alloc] init];
                _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                _window.rootViewController = _videoPlayerController;
                _window.tag = 20170701;
                [_window makeKeyAndVisible];
            }
            [_videoPlayerController play:url];
        } else {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [[delegate window] makeKeyAndVisible];
            _videoPlayerController = nil;
            _window = nil;
        }
    }];
    
    
//    [self.navigationController.view addSubview:_videoPlayerController.view];
//    [self.navigationController addChildViewController:_videoPlayerController];
//    [_videoPlayerController didMoveToParentViewController:self.navigationController];
//    
//    [_videoPlayerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(_videoPlayerController.view.superview);
//        make.right.equalTo(_videoPlayerController.view.superview);
//        make.bottom.equalTo(_videoPlayerController.view.superview);
//        make.top.equalTo(_videoPlayerController.view.superview);
//    }];
//    
//    _videoPlayerController.view.hidden = YES;
    
    //loading image
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:6];
    for(NSInteger i = 0; i < 6; i++) {
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"propeller_horizon_%ld", i * 30]]];
    }
    
    self.indicatorView = [[UIImageView alloc] init];
    self.indicatorView.image = nil;
    self.indicatorView.animationImages = images;
    [self.indicatorView startAnimating];
    self.indicatorView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.indicatorView];
//    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//        make.width.mas_equalTo(120);
//        make.height.mas_equalTo(120);
//    }];
    self.indicatorView.hidden = YES;
    
    self.viewModel = [[SPVCreationModel alloc] init];
    
    RACSignal *startedMessageSource = [self.viewModel.fetchContentCommand.executionSignals map:^id(RACSignal *subscribeSignal) {
        return [NSNumber numberWithBool:YES];
    }];
   
    RACSignal *completedMessageSource = [self.viewModel.fetchContentCommand.executionSignals flattenMap:^__kindof RACSignal * _Nullable(RACSignal *subscribeSignal) {
        return [[[subscribeSignal materialize] filter:^BOOL(RACEvent *event) {
            return event.eventType == RACEventTypeCompleted;
        }] map:^id(id value) {
            return [NSNumber numberWithBool:NO];
        }];
    }];
                                         
//    RACSignal *completedMessageSource = [self.viewModel.fetchContentCommand.executionSignals flattenMap:^RACStream *(RACSignal *subscribeSignal) {
//        return [[[subscribeSignal materialize] filter:^BOOL(RACEvent *event) {
//            return event.eventType == RACEventTypeCompleted;
//        }] map:^id(id value) {
//            return [NSNumber numberWithBool:NO];
//        }];
//    }];
    
    @weakify(self);
    [[completedMessageSource deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView reloadData];
    }];
    
    RACSignal *failedMessageSource = [[self.viewModel.fetchContentCommand.errors subscribeOn:[RACScheduler mainThreadScheduler]] map:^id(NSError *error) {
        return [NSNumber numberWithBool:NO];
    }];
    
    [[[RACSignal merge:@[startedMessageSource, completedMessageSource, failedMessageSource]] deliverOnMainThread]subscribeNext:^(NSNumber *running) {
        @strongify(self);
        self.indicatorView.hidden = ![running boolValue];
    }];
    
    self.flowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width,
                                          self.collectionView.bounds.size.width * 382 / 670 + DESCRIPTION_HEIGHT);
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if([[self.viewModel pages] objectForKey:@(0)] == nil) {
        [self.viewModel.fetchContentCommand execute: [NSNumber numberWithInteger:1]];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    NSURL *url = [NSURL URLWithString:@"http://dn-djidl2.qbox.me/cloud/3d8dbe68f01a548a95cf46803010a37d/sd.mp4?sign=3d2ad320611444e1ef4734a0b4323b04&t=59576dca"];
//    MobilePlayerViewController *vc=[[MobilePlayerViewController alloc] initWithContentURL:url];
//    //http://dn-djidl2.qbox.me/cloud/3d8dbe68f01a548a95cf46803010a37d/sd.mp4?sign=3d2ad320611444e1ef4734a0b4323b04&t=59576dca
//    
//    vc.activityItems = @[url];
//    [vc play];
//    [self presentViewController:vc animated:YES completion:nil];
}
#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.viewModel pages] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *items = [[self.viewModel pages] objectForKey:[NSNumber numberWithInteger:section]];
    return items == nil ? 0 : [items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    SPVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSArray *items = [[self.viewModel pages] objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    NSDictionary *viewModel = [items objectAtIndex:indexPath.row];
    [self configreCell:cell withViewModel:viewModel];
    
//    @weakify(self);
//    [[[cell.playCommand.executionSignals flattenMap:^RACStream *(RACSignal *signal) {
//        return signal;
//    }] deliverOnMainThread] subscribeNext:^(NSString *playURL) {
//        @strongify(self);
//        [self playeVideo:playURL];
//    }];
    return cell;
}

-(void) configreCell:(SPVCollectionViewCell *) cell withViewModel:(NSDictionary *) viewModel {
    [cell setViewModel:viewModel];
}

-(void) playeVideo:(NSString *) playerURL {
    if(![playerURL isKindOfClass:[NSString class]] || [playerURL length] == 0) {
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:playerURL]];
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(id x) {
        
    }];
}
#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *items = [[self.viewModel pages] objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    
    if(indexPath.row == [items count] - 1 && [[self.viewModel pages] objectForKey:@(indexPath.section + 1)] == nil) {
        [self.viewModel.fetchContentCommand execute: [NSNumber numberWithInteger:indexPath.section + 1 + 1]];
    }
}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Detail"]) {
        ImageDetailViewController *vc = segue.destinationViewController;
        UICollectionViewCell *cell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        NSArray *items = [[self.viewModel pages] objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        NSDictionary *viewModel = [items objectAtIndex:indexPath.row];
        [vc setModel:viewModel];
    }
}
@end
