//
//  VideoViewModel.m
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/07/02.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "VideoViewModel.h"

@implementation VideoViewModel

-(instancetype) init {
    self = [super init];
    if(self) {
        _videoURLSignal = [[[RACSubject subject] init] setNameWithFormat:@"videoURLSignal"];
    }
    return self;
}

-(void) setURL:(NSString *)URL {
    if([_URL isEqualToString:URL]) {
        return;
    }
    if(_disposable) {
        [_disposable dispose];
    }
    self.videoDefinitions = nil;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    RACSignal *signal = [NSURLConnection rac_sendAsynchronousRequest:request];
    _disposable = [signal subscribeNext:^(RACTuple *tuple) {
        NSString *jsonString = nil;
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)[tuple first];
        if([response statusCode] == 200) {
            NSData *data = [tuple second];
            
            NSString *playHTML = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(playHTML) {
                NSScanner *scanner = [NSScanner scannerWithString:playHTML];
                BOOL result = [scanner scanUpToString:@"videoDefinitions" intoString:nil];
                if(result && ![scanner isAtEnd]) {
                    result = [scanner scanUpToString:@"[{" intoString:nil];
                    if(result && ![scanner isAtEnd]) {
                        result = [scanner scanUpToString:@"}]" intoString:&jsonString];
                        
                        if(result && ![scanner isAtEnd]) {
                            jsonString = [jsonString stringByAppendingString:@"}]"];
                        }
                    }
                }
            }
        }
        
        self.videoDefinitions = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        if([self.videoDefinitions count]) {
            [_videoURLSignal sendNext:self.videoDefinitions];
        } else {
            [_videoURLSignal sendError:nil];
        }
    }];
}
@end
