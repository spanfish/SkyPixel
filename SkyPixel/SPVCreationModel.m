//
//  SPVCreationModel.m
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/06/28.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "SPVCreationModel.h"
#import <ReactiveCocoa.h>

@implementation SPVCreationModel

-(instancetype) init {
    self = [super init];
    if(self) {
        _updatedContentSignal = [[RACSubject subject] setNameWithFormat:@"SPVCreationModel updatedContentSignal"];
        @weakify(self)
        [self.didBecomeActiveSignal subscribeNext:^(id x) {
            @strongify(self);
            NSLog(@"x:%@", x);
            [((RACSubject *)self.updatedContentSignal) sendNext:@YES];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.skypixel.com/api/website/resources/works/?page=1&page_size=26&resourceType=&type=latest"]];
            [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple * x) {
                NSLog(@"fetchSingal:%@", [x second]);
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[x second]
                                                options:NSJSONReadingMutableContainers
                                                                       error:nil];
                [((RACSubject *)self.updatedContentSignal) sendNext:json];
                [((RACSubject *)self.updatedContentSignal) sendNext:@NO];
            }];
        }];
    }
    return self;
}
@end
