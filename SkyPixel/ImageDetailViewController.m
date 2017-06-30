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
@end

@implementation ImageDetailViewController

-(void) setModel:(NSDictionary *) model {
    self.detailViewModel = [[SPVDetailModel alloc] initWithModel:model];
    self.commentModel = [[SPVCommentModel alloc] initWithModel:model];
    
    RAC(self, title) = [RACObserve(self, detailViewModel)
                        map:^id(SPVDetailModel *value) {
                            NSString *title = [value.model objectForKey:@"title"];
                            return title;
                        }];

    @weakify(self)
    [[[self.detailViewModel.updatedContentSignal
       take:1]
      deliverOnMainThread]
     subscribeNext:^(NSDictionary *model) {
         @strongify(self);
         NSLog(@"model:%@", model);
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
     }];
    
    [[[self.commentModel.updatedContentSignal
       take:1]
      deliverOnMainThread]
     subscribeNext:^(NSDictionary *model) {
         @strongify(self);
         NSLog(@"comment:%@", model);
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.detailViewModel.active = YES;
    self.commentModel.active = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
            }
            
        } else if(indexPath.row == 1) {
            return 80;
        }
    } else if(indexPath.section == 2) {
        return [self tableView:self.tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    
    
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 2) {
        if(indexPath.row < [self.commentModel.comments count]) {
            NSDictionary *model = [self.commentModel.comments objectAtIndex:indexPath.row];
            NSString *comment = [model objectForKey:@"content"];
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
            CGRect rect = [comment boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width - 20, CGFLOAT_MAX)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:attributes
                                                      context:nil];
            return rect.size.height + 30;
        } else {
            return 30;
        }
        
    }
    
    return 80;
}
@end
