//
//  ImageDetailViewController.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "ImageDetailViewController.h"
#import <ReactiveCocoa.h>
#import "SPVDetailModel.h"
#import "ImageTableViewCell.h"
#import "ImageTitleTableViewCell.h"

@interface ImageDetailViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) SPVDetailModel *detailViewModel;
@property (nonatomic) SPVCommentModel *commentModel;
@property (nonatomic) SPVRelatedModel *relatedModel;
@property (nonatomic) SPVAlsoLikeModel *alsoLikeModel;
@end

@implementation ImageDetailViewController

-(void) setModel:(NSDictionary *) model {
    self.detailViewModel = [[SPVDetailModel alloc] initWithModel:model];
    self.commentModel = [[SPVCommentModel alloc] initWithModel:model];
    self.relatedModel = [[SPVRelatedModel alloc] initWithModel:model];
    self.alsoLikeModel = [[SPVAlsoLikeModel alloc] initWithModel:model];
    
    RAC(self, title) = [RACObserve(self, detailViewModel)
                        map:^id(SPVDetailModel *value) {
                            NSString *title = [value.model objectForKey:@"title"];
                            return title;
                        }];

    @weakify(self);
    [[[[[self.detailViewModel.updatedContentSignal combineLatestWith:self.commentModel.updatedContentSignal]
             combineLatestWith:self.relatedModel.updatedContentSignal]
     combineLatestWith:self.alsoLikeModel.updatedContentSignal]
      deliverOnMainThread]
     subscribeNext:^(id x) {
        @strongify(self);
         NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
         if(self.detailViewModel.modelData) {
             [indexSet addIndex:0];
         }
         if([self.commentModel.comments count] > 0) {
             [indexSet addIndex:2];
         }
         if([self.relatedModel.relatedArray count] > 0) {
             [indexSet addIndex:3];
         }
         if([self.alsoLikeModel.alsoLikeArray count] > 0) {
             [indexSet addIndex:4];
         }
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.tableView.estimatedRowHeight = 50;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.detailViewModel.active = YES;
    self.commentModel.active = YES;
    self.relatedModel.active = YES;
    self.alsoLikeModel.active = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:section];
    if(rows == 0) {
        return nil;
    }
    
    if(section == 0) {
        return nil;
    } else if(section == 1) {
        return nil;
    } else if(section == 2) {
        return @"Comments";
    } else if(section == 3) {
        return @"Related";
    } else if(section == 4) {
        return @"Also like";
    }
    return nil;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    //0: image
    //1: sns
    //2: comment
    //3: related
    //4: also like
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 2;
    } else if(section == 2) {
        return [self.commentModel.comments count];
    } else if(section == 3) {
        return [self.relatedModel.relatedArray count] > 0 ? 1 : 0;
    } else if(section == 4) {
        return [self.alsoLikeModel.alsoLikeArray count] > 0 ? 1 : 0;
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Image"];
            cell.model = self.detailViewModel.modelData;
            return cell;
        } else {
            ImageTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Info"];
            cell.model = self.detailViewModel.modelData;
            return cell;
        }
    } else if(indexPath.section == 2) {
        CommentTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
        cell.model = [self.commentModel.comments objectAtIndex:indexPath.row];
        return cell;
    } else if(indexPath.section == 3) {
        ResourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Resources"];
        cell.model = self.relatedModel.relatedArray;
        return cell;
    } else if(indexPath.section == 4) {
        ResourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Resources"];
        cell.model = self.alsoLikeModel.alsoLikeArray;
        
        return cell;
    }
    
    
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            NSDictionary *dict = self.detailViewModel.modelData;
            if(dict) {
                CGFloat width = [[dict objectForKey:@"width"] floatValue];
                CGFloat height = [[dict objectForKey:@"height"] floatValue];
                if(width > 0) {
                    CGFloat cellHeight = self.tableView.bounds.size.width * height / width;
                    return cellHeight + 5/*space between image and camera*/ + 22/*camera height*/ + 22/*shutter height*/ + 10/*space between camera and shutter*/ + 10/*space between shutter and bottom*/;
                }
            } else {
                return 0;
            }
        } else if(indexPath.row == 1) {
            return 80;
        }
    } else if(indexPath.section == 2) {
        CommentTableViewCell *cell = (CommentTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        cell.model = [self.commentModel.comments objectAtIndex:indexPath.row];
        [cell layoutIfNeeded];
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return size.height + 1/*line seperator*/ + 30;
    } else if(indexPath.section == 3) {
        return 155 + 1;
    } else if(indexPath.section == 4) {
        return 155 + 1;
    }
    
    return UITableViewAutomaticDimension;
}


-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
