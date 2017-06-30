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

@implementation SPVCommentModel

-(instancetype) initWithModel:(id)model {
    self = [super initWithModel:model];
    if(self) {
        _comments = [NSMutableArray array];
        _updatedContentSignal = [[RACSubject subject] setNameWithFormat:@"SPVCommentModel updatedContentSignal"];
        
        @weakify(self)
        [self.didBecomeActiveSignal subscribeNext:^(id x) {
            @strongify(self);
            [self fetchComment];
        }];
    }
    
    return self;
}

-(void) fetchComment {
    //https://www.skypixel.com/api/website/photos/02da2ae1-5c37-4c74-aed5-b955348309f1
    //https://www.skypixel.com/api/website/videos/d2c1dda3-5269-4ab6-abe8-42ed613fbdce
    NSString *type = [self.model objectForKey:@"type"];
    NSString *rid = [self.model objectForKey:@"id"];
    NSString *url = [NSString stringWithFormat:@"https://www.skypixel.com/api/website/%@s/%@/comments?page=%d&page_size=10",
                     type,
                     rid,
                     1];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    @weakify(self)
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        @strongify(self);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[x second]
                                                     options:NSJSONReadingMutableContainers
                                                       error:nil];
        NSArray *array = [dict objectForKey:@"comments"];
        if([array isKindOfClass:[NSArray class]] && [array count] > 0) {
            [self.comments addObjectsFromArray:array];
        }
        
        [((RACSubject *)self.updatedContentSignal) sendNext:_comments];
        [((RACSubject *)self.updatedContentSignal) sendCompleted];
    }];
}
@end
