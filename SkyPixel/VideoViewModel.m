//
//  VideoViewModel.m
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/07/03.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "VideoViewModel.h"

@implementation VideoViewModel

-(instancetype) initWithModel:(id)model {
    self = [super initWithModel:model];
    if(self) {
        self.videoDefinitionsSignal = [[[RACSubject subject] init] setNameWithFormat:@"videoReadySignal"];
        [self loadVideoURL];
    }
    
    return self;
}

-(void) loadVideoURL {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: self.model]];
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple *tuple) {
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
            [self.videoDefinitionsSignal sendNext:self.videoDefinitions];
            [self.videoDefinitionsSignal sendCompleted];
        } else {
            [self.videoDefinitionsSignal sendError:nil];
        }
    }];
}
@end
