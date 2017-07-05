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
#import <Masonry.h>
#import "AppDelegate.h"
#import "PlayerViewController.h"
#import "LoadingView.h"

#pragma mark - SectionHeadView
@interface FlowLayout : UICollectionViewFlowLayout

@end

@implementation FlowLayout

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    return [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
}
@end

#pragma mark - SectionHeadView
@interface SectionHeaderView : UICollectionReusableView

@end

@implementation SectionHeaderView

@end

#pragma mark - SectionFooterView
@interface SectionFooterView : UICollectionReusableView

@property(nonatomic, weak) IBOutlet UIImageView *moreImageView;
@end

@implementation SectionFooterView

@end

#pragma mark -

#define DESCRIPTION_HEIGHT 50
@import GoogleMobileAds;
@interface MainCollectionViewController ()<GADBannerViewDelegate, UICollectionViewDelegateFlowLayout> {
    UIWindow *_window;
    GADBannerView *_bannerView;
    NSInteger _adSection;
    LoadingView *_loadingView;
}

//@property (nonatomic, strong) UIImageView *indicatorView;
@property (nonatomic, weak) IBOutlet FlowLayout *flowLayout;
@property (nonatomic) SPVCreationModel *viewModel;
@end

@implementation MainCollectionViewController

#pragma mark - AD
-(void) configureAdView {
    _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner];

    _bannerView.adUnitID = @"ca-app-pub-5834401851232277/2795862548";
    _bannerView.rootViewController = self;
    _bannerView.delegate = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ kGADSimulatorID,                       // All simulators
                             @"e3d8833a984532558d9da4ce773d020a",
                             @"89bc7a04a2caafab68af170673d7eff8"]; // Sample device ID
    [_bannerView loadRequest:request];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"adViewDidReceiveAd");
    _adSection = 0;
    if([[self.viewModel pages] count] > 0) {
        NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
        NSIndexPath *indexPath = [indexPaths lastObject];
        _adSection = indexPath.section;
    }

    [self.collectionView reloadData];
}

/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"didFailToReceiveAdWithError:%@", error);
    _adSection = -1;
    [self.collectionView reloadData];
}
#pragma mark -

-(void) configureLoadingView {
    if(!_loadingView) {
        _loadingView = [[[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil] firstObject];
        [self.view addSubview:_loadingView];
        [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.edges.equalTo(_loadingView.superview);
            make.width.equalTo(_loadingView.superview);
            make.centerX.equalTo(_loadingView.superview);
            make.top.mas_equalTo(40);
            make.height.mas_equalTo(90);
        }];
    }
    
    //[_loadingView.loadingImageView startAnimating];
    _loadingView.textLabel.text = @"Loading...";
    _loadingView.hidden = NO;
}

-(void) configureCollectionViewLayout {
    self.flowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width,
                                          self.collectionView.bounds.size.width * 382 / 670 + DESCRIPTION_HEIGHT);
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsZero;
    self.flowLayout.sectionHeadersPinToVisibleBounds = NO;
    self.flowLayout.sectionFootersPinToVisibleBounds = YES;
}

-(void) configurePlayer {
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"play" object:nil] map:^id(NSNotification *notification) {
        return [notification object];
    }] deliverOnMainThread] subscribeNext:^(NSString *url) {
        NSLog(@"video:%@", url);
        if(url) {
            if(!_window) {
                PlayerViewController *vc = [[PlayerViewController alloc] initWithURL:url];
                _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                _window.rootViewController = vc;
                _window.tag = 20170701;
                [_window makeKeyAndVisible];
            }
        } else {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [[delegate window] makeKeyAndVisible];
            _window = nil;
        }
    }];
}

-(void) configureViewModel {
    self.viewModel = [[SPVCreationModel alloc] init];
    
    @weakify(self);
    [[self.viewModel.contentUpdatedSignal deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        NSLog(@"%s %d, :%@ %@", __FILE__, __LINE__, @"contentUpdatedSignal", x);
        if([[self.viewModel.pages objectForKey:@1] count] > 0) {
            _loadingView.hidden = YES;
        } else {
            _loadingView.hidden = NO;
        }
        
        [self.collectionView reloadData];
    } error:^(NSError *error) {
        NSLog(@"%s %d, :%@", __FILE__, __LINE__, error);
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger day = [components day];
        NSInteger month = [components month];
        NSInteger year = [components year];
        if(year == 2017 && month == 7 && day < 7 && [[[self.viewModel pages] objectForKey:@1] count] == 0) {
            [self.viewModel configureDefault];
            [self.collectionView reloadData];
            if([[self.viewModel.pages objectForKey:@1] count] > 0) {
                _loadingView.hidden = YES;
            } else {
                _loadingView.hidden = NO;
            }
        } else {
            if([[self.viewModel.pages objectForKey:@1] count] == 0) {
                _loadingView.hidden = NO;
                [_loadingView.loadingImageView stopAnimating];
                _loadingView.textLabel.text = error ? [error localizedDescription] : NSLocalizedString(@"Failed to load data", nil);
            } else {
                _loadingView.hidden = YES;
            }
        }
    }];
    
    [[self.viewModel.fetchContentCommand.errors subscribeOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSError *error) {
        NSLog(@"%s %d, :%@", __FILE__, __LINE__, error);
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger day = [components day];
        NSInteger month = [components month];
        NSInteger year = [components year];
        if(year == 2017 && month == 7 && day < 7 && [[[self.viewModel pages] objectForKey:@1] count] == 0) {
            [self.viewModel configureDefault];
            [self.collectionView reloadData];
            if([[self.viewModel.pages objectForKey:@1] count] > 0) {
                _loadingView.hidden = YES;
            } else {
                _loadingView.hidden = NO;
            }
        } else {
            if([[self.viewModel.pages objectForKey:@1] count] == 0) {
                _loadingView.hidden = NO;
                [_loadingView.loadingImageView stopAnimating];
                _loadingView.textLabel.text = error ? [error localizedDescription] : NSLocalizedString(@"Failed to load data", nil);
            } else {
                _loadingView.hidden = YES;
            }
        }
    }];
}
#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
#if DEBUG
#endif
    self.title = NSLocalizedString(@"Creations", nil);
    
    [self configureAdView];

    [self configureLoadingView];
    
    [self configurePlayer];

    [self configureCollectionViewLayout];
    
    [self configureViewModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if([[self.viewModel pages] objectForKey:@(1)] == nil) {
        _loadingView.hidden = NO;
        [_loadingView.loadingImageView startAnimating];
        _loadingView.textLabel.text = @"Loading...";
        [self.viewModel.fetchContentCommand execute: [NSNumber numberWithInteger:1]];
    }
}

-(IBAction)refreshTouched:(id)sender {
    if([[[self.viewModel pages] objectForKey:@1] count] > 0) {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    }
    _loadingView.hidden = NO;
    [_loadingView.loadingImageView startAnimating];
    _loadingView.textLabel.text = @"Loading...";
    [self.viewModel.fetchContentCommand execute: [NSNumber numberWithInteger:1]];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.viewModel pages] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *items = [[self.viewModel pages] objectForKey:[NSNumber numberWithInteger:section + 1]];
    return items == nil ? 0 : [items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    SPVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSArray *items = [[self.viewModel pages] objectForKey:[NSNumber numberWithInteger:indexPath.section + 1]];
    NSDictionary *viewModel = [items objectAtIndex:indexPath.row];
    [self configreCell:cell withViewModel:viewModel];
    
    return cell;
}

-(UICollectionReusableView *) collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if([UICollectionElementKindSectionFooter isEqualToString:kind]) {
        SectionFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                           withReuseIdentifier:@"SectionFooter"
                                                                                  forIndexPath:indexPath];
        for(UIView *view in footerView.subviews) {
            [view removeFromSuperview];
        }
        [_bannerView removeFromSuperview];
        [footerView addSubview:_bannerView];
        [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(footerView);
        }];
        return footerView;

    } else if([UICollectionElementKindSectionHeader isEqualToString:kind]) {
        //SectionHeader
        SectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                           withReuseIdentifier:@"SectionHeader"
                                                                                  forIndexPath:indexPath];
        return headerView;
    }

    return nil;
}

-(void) configreCell:(SPVCollectionViewCell *) cell withViewModel:(NSDictionary *) viewModel {
    [cell setViewModel:viewModel];
}
#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *items = [[self.viewModel pages] objectForKey:[NSNumber numberWithInteger:indexPath.section + 1]];
    
    if(indexPath.row == [items count] - 1 && [[self.viewModel pages] objectForKey:@(indexPath.section + 2)] == nil) {
        NSLog(@"%s %d, :%@", __FILE__, __LINE__, @"will fetch content");
        _loadingView.hidden = NO;
        [_loadingView.loadingImageView startAnimating];
        _loadingView.textLabel.text = @"Loading...";
        [[self.viewModel.fetchContentCommand execute: [NSNumber numberWithInteger:indexPath.section + 2]] logAll];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    if([[self.viewModel pages] count] > 0 && _adSection > -1) {
        return CGSizeMake(320, _bannerView.bounds.size.height);
    }
    
    return CGSizeZero;
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
        NSArray *items = [[self.viewModel pages] objectForKey:[NSNumber numberWithInteger:indexPath.section + 1]];
        NSDictionary *viewModel = [items objectAtIndex:indexPath.row];
        [vc setModel:viewModel];
    }
}
@end
