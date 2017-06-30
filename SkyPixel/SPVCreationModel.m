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

@interface SPVCreationModel() {
    NSMutableDictionary *_pages;
}
@end

@implementation SPVCreationModel

-(instancetype) init {
    self = [super init];
    if(self) {
        _pages = [NSMutableDictionary dictionary];
        _fetchContentCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSNumber *pageNo) {
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.skypixel.com/api/website/resources/works/?page=%ld&page_size=26&resourceType=&type=latest",  [pageNo integerValue]]]];
            
            RACSignal *signal = [NSURLConnection rac_sendAsynchronousRequest:request];
            [signal subscribeNext:^(RACTuple *response) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[response second]
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
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
                [_pages setObject:all forKey:@([pageNo integerValue]  - 1)];
            }];
            [signal setName:@"rac_sendAsynchronousRequest"];
            return signal;
        }];
        _fetchContentCommand.allowsConcurrentExecution = NO;
    }
    return self;
}

-(NSDictionary *) pages {
    return _pages;
}
@end
