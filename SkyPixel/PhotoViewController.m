//
//  PhotoViewController.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/07/04.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundColorVisible = [UIColor blackColor];
    self.view.backgroundColor = [UIColor blackColor];
    self.progressColorHidden = [UIColor blackColor];
    self.progressColorVisible = [UIColor blackColor];
    self.rotationEnabled = NO;
    self.scrollView.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
