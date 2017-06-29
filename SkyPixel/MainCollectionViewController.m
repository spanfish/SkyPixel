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
#import "YRCoverFlowLayout.h"

@interface MainCollectionViewController () {
    CGSize _originalItemSize;
    CGSize _originalCollectionViewSize;
}

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet YRCoverFlowLayout *coverFlowLayout;
@property (nonatomic) SPVCreationModel *creationModel;
@end

@implementation MainCollectionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.creationModel = [[SPVCreationModel alloc] init];
    @weakify(self);
    [[[self.creationModel.updatedContentSignal filter:^BOOL(id value) {
        if([value isKindOfClass:[NSNumber class]]) {
            return NO;
        }
        return YES;
    }]
    deliverOnMainThread]
    subscribeNext:^(id x) {
        @strongify(self);
        NSLog(@"updatedContentSignal");
        [self.collectionView reloadData];
    }];
    
    [[[self.creationModel.updatedContentSignal filter:^BOOL(id value) {
        if([value isKindOfClass:[NSNumber class]]) {
            return YES;
        }
        return NO;
    }]
      deliverOnMainThread]
     subscribeNext:^(id x) {
        @strongify(self);
         if([x boolValue]) {
             [self.indicatorView startAnimating];
         } else {
             [self.indicatorView stopAnimating];
         }
    }];
    //RAC(self.indicatorView, loading) = self.creationModel.fetchContentSignal;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    _originalItemSize = _coverFlowLayout.itemSize;
    _originalCollectionViewSize = self.collectionView.bounds.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.creationModel.active = YES;
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.creationModel.active = YES;
}

- (void)viewWillLayoutSubviews {
    //[super viewWillLayoutSubviews];
    
    // We should invalidate layout in case we are switching orientation.
    // If we won't do that we will receive warning from collection view's flow layout that cell size isn't correct.
    //[_coverFlowLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews {
    //[super viewDidLayoutSubviews];
    
    // Now we should calculate new item size depending on new collection view size.
    _coverFlowLayout.itemSize = (CGSize){
        self.collectionView.bounds.size.width * _originalItemSize.width / _originalCollectionViewSize.width,
        self.collectionView.bounds.size.height * _originalItemSize.height / _originalCollectionViewSize.height
    };
    
    // Forcely tell collection view to reload current data.
    //[self.collectionView setNeedsLayout];
    //[self.collectionView layoutIfNeeded];
    [self.collectionView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.creationModel.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    SPVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *viewModel = [self.creationModel.items objectAtIndex:indexPath.row];
    [cell setViewModel:viewModel];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

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

@end
