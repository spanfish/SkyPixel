//
//  SPVDetailModel.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "SPVDetailModel.h"

@interface SPVDetailModel()

@property (nonatomic, readonly) RACSignal *infoSignal;
@property (nonatomic, readonly) RACSignal *commentSignal;
@property (nonatomic, readonly) RACSignal *relatedSignal;
@property (nonatomic, readonly) RACSignal *alsoLikeSignal;
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
            _infoSignal = [self fetchImageInfo];
            _commentSignal = [self fetchComment];
            _relatedSignal = [self fetchRelated];
            _alsoLikeSignal = [self fetchAlsoLike];
        }];
    }
    
    return self;
}

-(RACSignal *) fetchImageInfo {
    NSString *type = [self.model objectForKey:@"type"];
    NSString *rid = [self.model objectForKey:@"id"];
    NSString *url = [NSString stringWithFormat:@"https://www.skypixel.com/api/website/%@s/%@",
                     type,
                     rid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    RACSignal *signal = [NSURLConnection rac_sendAsynchronousRequest:request];
    [signal subscribeNext:^(RACTuple* x) {
        _imageInfo = [NSJSONSerialization JSONObjectWithData:[x second]
                                                     options:NSJSONReadingMutableContainers
                                                       error:nil];
        [_updatedContentSignal sendNext:@"image"];
    } error:^(NSError *error) {
        NSLog(@"%s %d, :%@", __FILE__, __LINE__, error);
    }];
    return signal;
}

-(RACSignal *) fetchComment {
    NSString *type = [self.model objectForKey:@"type"];
    NSString *rid = [self.model objectForKey:@"id"];
    NSString *url = [NSString stringWithFormat:@"https://www.skypixel.com/api/website/%@s/%@/comments?page=%d&page_size=10",
                     type,
                     rid,
                     1];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    RACSignal *signal = [NSURLConnection rac_sendAsynchronousRequest:request];
    [signal subscribeNext:^(RACTuple* x) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[x second]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        NSArray *array = [dict objectForKey:@"comments"];
        if([array isKindOfClass:[NSArray class]] && [array count] > 0) {
            [self.commentArray addObjectsFromArray:array];
        }
        
        [_updatedContentSignal sendNext:@"comment"];
    } error:^(NSError *error) {
        NSLog(@"%s %d, :%@", __FILE__, __LINE__, error);
    }];
    return signal;
}

-(RACSignal *) fetchRelated {
    NSString *type = [self.model objectForKey:@"type"];
    NSString *rid = [self.model objectForKey:@"id"];
    NSString *url = [NSString stringWithFormat:@"https://www.skypixel.com/api/website/%@s/%@/related_creations",
                     type,
                     rid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    @weakify(self)
    RACSignal *signal = [NSURLConnection rac_sendAsynchronousRequest:request];
    [signal subscribeNext:^(RACTuple* x) {
        @strongify(self);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[x second]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        NSArray *array = [dict objectForKey:@"resources"];
        if([array isKindOfClass:[NSArray class]] && [array count] > 0) {
            [self.relatedArray addObjectsFromArray:array];
        }
        
        [_updatedContentSignal sendNext:@"related"];
    } error:^(NSError *error) {
        NSLog(@"%s %d, :%@", __FILE__, __LINE__, error);
    }];
    return signal;
}

-(RACSignal *) fetchAlsoLike {
    NSString *type = [self.model objectForKey:@"type"];
    NSString *rid = [self.model objectForKey:@"id"];
    NSString *url = [NSString stringWithFormat:@"https://www.skypixel.com/api/website/%@s/%@/also_likes",
                     type,
                     rid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    @weakify(self)
    RACSignal *signal = [NSURLConnection rac_sendAsynchronousRequest:request];
    [signal subscribeNext:^(RACTuple* x) {
        @strongify(self);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[x second]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        NSArray *array = [dict objectForKey:@"resources"];
        if([array isKindOfClass:[NSArray class]] && [array count] > 0) {
            [self.alsoLikeArray addObjectsFromArray:array];
        }
        
        [_updatedContentSignal sendNext:@"alsolike"];
    } error:^(NSError *error) {
        NSLog(@"%s %d, :%@", __FILE__, __LINE__, error);
    }];
    return signal;
}
@end
