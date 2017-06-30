//
//  SPVCreationModel.m
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/06/28.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "SPVCreationModel.h"
#import <ReactiveCocoa.h>
#include <stdlib.h>

@implementation SPVCreationModel

-(instancetype) init {
    self = [super init];
    if(self) {
        _updatedContentSignal = [[RACSubject subject] setNameWithFormat:@"SPVCreationModel updatedContentSignal"];
        @weakify(self)
        [self.didBecomeActiveSignal subscribeNext:^(id x) {
            @strongify(self);

            [self fetchCreationsForPage:1];
        }];
    }
    return self;
}

-(void) fetchCreationsForPage:(NSUInteger) page {
    [((RACSubject *)self.updatedContentSignal) sendNext:@YES];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.skypixel.com/api/website/resources/works/?page=%ld&page_size=26&resourceType=&type=latest", page]]];
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple * x) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[x second]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        //NSLog(@"json:%@", json);
        NSMutableArray *all = [NSMutableArray array];
        NSArray *photos = [json objectForKey:@"photos"];
        NSArray *panos = [json objectForKey:@"panos"];
        NSArray *videos = [json objectForKey:@"videos"];
        
        [all addObjectsFromArray:photos];
        for(NSInteger i = 0; i < [videos count]; i++) {
            NSInteger r = arc4random_uniform((int32_t)[all count]);
            [all insertObject:[videos objectAtIndex:i] atIndex:r];
        }
        for(NSInteger i = 0; i < [panos count]; i++) {
            NSInteger r = arc4random_uniform((int32_t)[all count]);
            [all insertObject:[panos objectAtIndex:i] atIndex:r];
        }
        _items = all;
        [((RACSubject *)self.updatedContentSignal) sendNext:nil];
        [((RACSubject *)self.updatedContentSignal) sendNext:@NO];
        [((RACSubject *)self.updatedContentSignal) sendCompleted];
    }];
}
@end
