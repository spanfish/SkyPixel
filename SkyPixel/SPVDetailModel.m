//
//  SPVDetailModel.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "SPVDetailModel.h"
#import <ReactiveCocoa.h>

@interface SPVDetailModel()
@end

@implementation SPVDetailModel

-(instancetype) initWithModel:(id)model {
    self = [super initWithModel:model];
    if(self) {
        _updatedContentSignal = [[RACSubject subject] setNameWithFormat:@"SPVDetailModel updatedContentSignal"];
        
        @weakify(self)
        [self.didBecomeActiveSignal subscribeNext:^(id x) {
            @strongify(self);
            [self fetchDetail];
        }];
    }
    
    return self;
}

-(void) fetchDetail {
    //https://www.skypixel.com/api/website/photos/02da2ae1-5c37-4c74-aed5-b955348309f1
    //https://www.skypixel.com/api/website/videos/d2c1dda3-5269-4ab6-abe8-42ed613fbdce
    NSString *type = [self.model objectForKey:@"type"];
    NSString *rid = [self.model objectForKey:@"id"];
    NSString *url = [NSString stringWithFormat:@"https://www.skypixel.com/api/website/%@s/%@",
                     type,
                     rid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    @weakify(self)
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        @strongify(self);
        _modelData = [NSJSONSerialization JSONObjectWithData:[x second]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        [((RACSubject *)self.updatedContentSignal) sendNext:_modelData];
        [((RACSubject *)self.updatedContentSignal) sendCompleted];
    }];
}
@end
