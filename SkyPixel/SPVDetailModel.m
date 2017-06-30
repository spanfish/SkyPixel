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
        _imageInfo = nil;
        _commentArray = [NSMutableArray array];
        _relatedArray = [NSMutableArray array];
        _alsoLikeArray = [NSMutableArray array];
        _updatedContentSignal = [[RACSubject subject] setNameWithFormat:@"SPVDetailModel updatedContentSignal"];
        @weakify(self)
        [self.didBecomeActiveSignal subscribeNext:^(id x) {
            @strongify(self);
            [self fetchImageInfo];
            [self fetchComment];
            [self fetchRelated];
            [self fetchAlsoLike];
        }];
    }
    
    return self;
}

-(void) fetchImageInfo {
    NSString *type = [self.model objectForKey:@"type"];
    NSString *rid = [self.model objectForKey:@"id"];
    NSString *url = [NSString stringWithFormat:@"https://www.skypixel.com/api/website/%@s/%@",
                     type,
                     rid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    @weakify(self)
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        @strongify(self);
        _imageInfo = [NSJSONSerialization JSONObjectWithData:[x second]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        [((RACSubject *)self.updatedContentSignal) sendNext:nil];
    }];
}

-(void) fetchComment {
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
            [self.commentArray addObjectsFromArray:array];
        }
        
        [((RACSubject *)self.updatedContentSignal) sendNext:nil];
    }];
}

-(void) fetchRelated {
    NSString *type = [self.model objectForKey:@"type"];
    NSString *rid = [self.model objectForKey:@"id"];
    NSString *url = [NSString stringWithFormat:@"https://www.skypixel.com/api/website/%@s/%@/related_creations",
                     type,
                     rid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    @weakify(self)
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        @strongify(self);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[x second]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        NSArray *array = [dict objectForKey:@"resources"];
        if([array isKindOfClass:[NSArray class]] && [array count] > 0) {
            [self.relatedArray addObjectsFromArray:array];
        }
        
        [((RACSubject *)self.updatedContentSignal) sendNext:nil];
    }];
}

-(void) fetchAlsoLike {
    NSString *type = [self.model objectForKey:@"type"];
    NSString *rid = [self.model objectForKey:@"id"];
    NSString *url = [NSString stringWithFormat:@"https://www.skypixel.com/api/website/%@s/%@/also_likes",
                     type,
                     rid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    @weakify(self)
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        @strongify(self);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[x second]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        NSArray *array = [dict objectForKey:@"resources"];
        if([array isKindOfClass:[NSArray class]] && [array count] > 0) {
            [self.alsoLikeArray addObjectsFromArray:array];
        }
        
        [((RACSubject *)self.updatedContentSignal) sendNext:nil];
    }];
}
@end
