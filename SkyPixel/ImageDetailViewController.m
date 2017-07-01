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

typedef NS_ENUM(NSInteger, DetailSection) {
    IMAGE_SECTION,
    COMMENT_SECTION,
    RELATE_SECTION,
    ALSOLIKE_SECTION,
    NUM_OF_SECTION
};

@interface ImageDetailViewController () {
    NSInteger numOfRows[NUM_OF_SECTION];
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic) SPVDetailModel *viewModel;
@end

@implementation ImageDetailViewController

-(void) configureNumOfRows {
    numOfRows[IMAGE_SECTION] = 2;
    numOfRows[COMMENT_SECTION] = 0;
    numOfRows[RELATE_SECTION] = 0;
    numOfRows[ALSOLIKE_SECTION] = 0;
}
-(void) setModel:(NSDictionary *) model {
    [self configureNumOfRows];
    self.viewModel = [[SPVDetailModel alloc] initWithModel:model];
    
    RAC(self, title) = [RACObserve(self, viewModel)
                        map:^id(SPVDetailModel *value) {
                            NSString *title = [value.model objectForKey:@"title"];
                            return title;
                        }];

    @weakify(self);
    [[self.viewModel.updatedContentSignal deliverOnMainThread] subscribeNext:^(NSString *source) {
        @strongify(self);
        
        if([source isEqualToString:@"image"]) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:IMAGE_SECTION] withRowAnimation:UITableViewRowAnimationNone];
        } else if([source isEqualToString:@"comment"]) {
            numOfRows[COMMENT_SECTION] = [self.viewModel.commentArray count];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:COMMENT_SECTION] withRowAnimation:UITableViewRowAnimationNone];
        } else if([source isEqualToString:@"related"]) {
            numOfRows[RELATE_SECTION] = [self.viewModel.relatedArray count] > 0 ? 1 : 0;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:RELATE_SECTION] withRowAnimation:UITableViewRowAnimationNone];
        } else if([source isEqualToString:@"alsolike"]) {
            numOfRows[ALSOLIKE_SECTION] = [self.viewModel.alsoLikeArray count] > 0 ? 1 : 0;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ALSOLIKE_SECTION] withRowAnimation:UITableViewRowAnimationNone];
        }
        //[self.tableView reloadData];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel.active = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    
    if(section == IMAGE_SECTION) {
        return nil;
    } else if(section == COMMENT_SECTION) {
        return @"Comments";
    } else if(section == RELATE_SECTION) {
        return @"Related";
    } else if(section == ALSOLIKE_SECTION) {
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
    return NUM_OF_SECTION;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if(section == IMAGE_SECTION) {
//        return 2;
//    } else if(section == COMMENT_SECTION) {
//        return [self.viewModel.commentArray count];
//    } else if(section == RELATE_SECTION) {
//        return [self.viewModel.relatedArray count] > 0 ? 1 : 0;
//    } else if(section == ALSOLIKE_SECTION) {
//        return [self.viewModel.alsoLikeArray count] > 0 ? 1 : 0;
//    }
    return numOfRows[section];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == IMAGE_SECTION) {
        if(indexPath.row == 0) {
            ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Image"];
            [cell configureCellWithModel:self.viewModel.imageInfo];
            return cell;
        } else {
            ImageTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Info"];
            [cell configureCellWithModel: self.viewModel.imageInfo];
            return cell;
        }
    } else if(indexPath.section == COMMENT_SECTION) {
        CommentTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
        [cell configureCellWithModel:[self.viewModel.commentArray objectAtIndex:indexPath.row]];
        return cell;
    } else if(indexPath.section == RELATE_SECTION) {
        ResourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Resources"];
        [cell configureCellWithModel: self.viewModel.relatedArray];
        [[[cell.touchSignal deliverOnMainThread] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSDictionary *m) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ImageDetailViewController *vc =  [sb instantiateViewControllerWithIdentifier:@"Detail"];
            [vc setModel:m];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        return cell;
    } else if(indexPath.section == ALSOLIKE_SECTION) {
        ResourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Resources"];
        [cell configureCellWithModel:self.viewModel.alsoLikeArray];
        [[[cell.touchSignal deliverOnMainThread] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSDictionary *m) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ImageDetailViewController *vc =  [sb instantiateViewControllerWithIdentifier:@"Detail"];
            [vc setModel:m];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        return cell;
    }
    
    
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == IMAGE_SECTION) {
        if(indexPath.row == 0) {
            NSDictionary *dict = self.viewModel.imageInfo;
            if(dict) {
                CGFloat width = [[dict objectForKey:@"width"] floatValue];
                CGFloat height = [[dict objectForKey:@"height"] floatValue];
                if(width > 0) {
                    CGFloat cellHeight = self.tableView.bounds.size.width * height / width;
                    return cellHeight + 5/*space between image and camera*/ + 22/*camera height*/ + 22/*shutter height*/ + 10/*space between camera and shutter*/ + 10/*space between shutter and bottom*/;
                }
            } else {
                return self.tableView.bounds.size.height - 100;
            }
        } else if(indexPath.row == 1) {
            return 80;
        }
    } else if(indexPath.section == COMMENT_SECTION) {
        CommentTableViewCell *cell = (CommentTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        [cell configureCellWithModel: [self.viewModel.commentArray objectAtIndex:indexPath.row]];
        [cell layoutIfNeeded];
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return size.height + 1/*line seperator*/ + 30;
    } else if(indexPath.section == RELATE_SECTION) {
        return 155 + 1;
    } else if(indexPath.section == ALSOLIKE_SECTION) {
        return 155 + 1;
    }
    
    return UITableViewAutomaticDimension;
}


-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


@end
