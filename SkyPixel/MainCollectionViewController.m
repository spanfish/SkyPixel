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

#define DESCRIPTION_HEIGHT 50

@interface MainCollectionViewController () {

}

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *flowLayout;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionViewHeightConstraint;
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
    self.view.layer.cornerRadius = 6;
    self.view.layer.borderWidth = 1;
    //RAC(self.indicatorView, loading) = self.creationModel.fetchContentSignal;
    self.flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width,
                                          self.view.bounds.size.width * 382 / 670 + DESCRIPTION_HEIGHT);
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsZero;
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
//    self.creationModel.active = YES;
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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Detail"]) {
        ImageDetailViewController *vc = segue.destinationViewController;
        UICollectionViewCell *cell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        NSDictionary *viewModel = [self.creationModel.items objectAtIndex:indexPath.row];
        [vc setModel:viewModel];
    }
}
@end
