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

@interface ImageDetailViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) SPVDetailModel *detailViewModel;
@end

@implementation ImageDetailViewController

-(void) setModel:(NSDictionary *) model {
    self.detailViewModel = [[SPVDetailModel alloc] initWithModel:model];
    
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
         [self.tableView reloadData];
     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.detailViewModel.active = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Image"];
    cell.model = self.detailViewModel.modelData;
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        
    }
    
    return 0;
}
@end
