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

@interface ImageDetailViewController ()

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

    [[self.detailViewModel.updatedContentSignal
      deliverOnMainThread]
     subscribeNext:^(NSDictionary *model) {
         NSLog(@"model:%@", model);
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

@end
