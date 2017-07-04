//
//  SPVImageView.m
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/07/01.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "SPVImageView.h"
#import <ReactiveCocoa.h>

@interface SPVImageView() {
    RACCommand *_loadImageCommand;
    RACDisposable *_loadDisposable;
}

@end

@implementation SPVImageView

-(instancetype) init {
    self = [super init];
    if(self) {
        [self commonInit];
    }
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self commonInit];
    }
    return self;
}


-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}


-(instancetype) initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if(self) {
        [self commonInit];
    }
    return self;
}


-(instancetype) initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if(self) {
        [self commonInit];
    }
    return self;
}

-(void) commonInit {
    _imageLoadedSignal = [[RACSubject subject] setNameWithFormat:@"imageLoadedSignal"];
    _loadImageCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *path) {
        NSLog(@"download image:%@", path);
        NSString *fileName = [path lastPathComponent];
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        cachePath = [cachePath stringByAppendingPathComponent:fileName];
        if([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                UIImage *image = [UIImage imageWithContentsOfFile:cachePath];
                [_imageLoadedSignal sendNext:image];
                
                RACTuple *tuple = [RACTuple tupleWithObjects:@"", image, nil];
                [subscriber sendNext:tuple];
                [subscriber sendCompleted];
                return nil;
            }];

            
            return signal;
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        RACSignal *signal = [NSURLConnection rac_sendAsynchronousRequest:request];
        _loadDisposable = [signal subscribeNext:^(RACTuple *imageTuple) {
            NSURLResponse *response = [imageTuple first];
            NSData *data = [imageTuple second];
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
            cachePath = [cachePath stringByAppendingPathComponent: [[[response URL] path] lastPathComponent]];
            NSLog(@"image downloaded:%@, thread:%@", [cachePath lastPathComponent], [[NSThread currentThread] isMainThread] ? @"Main" : @"Non main");
            if(data && ![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
                [data writeToFile:cachePath atomically:YES];
            }
            
        }];
        return signal;
    }];
    
    RACSignal *startedMessageSource = [_loadImageCommand.executionSignals map:^id(RACSignal *subscribeSignal) {
        return [NSNumber numberWithBool:YES];
    }];
    
    RACSignal *completedMessageSource = [_loadImageCommand.executionSignals flattenMap:^RACStream *(RACSignal *subscribeSignal) {
        return [[[subscribeSignal materialize] filter:^BOOL(RACEvent *event) {
            return event.eventType == RACEventTypeCompleted;
        }] map:^id(id value) {
            return [NSNumber numberWithBool:NO];
        }];
    }];
    
    [[[_loadImageCommand.executionSignals flattenMap:^RACStream *(RACSignal *subscribeSignal) {
        return subscribeSignal;
    }] deliverOnMainThread] subscribeNext:^(RACTuple *value) {
        if([[value second] isKindOfClass:[UIImage class]]) {
            self.image = [value second];
        } else if([[value second] isKindOfClass:[NSData class]]) {
            self.image = [UIImage imageWithData:[value second]];
            [_imageLoadedSignal sendNext:self.image];
        }
        self.contentMode = UIViewContentModeScaleAspectFill;
    }];
    
    RACSignal *failedMessageSource = [[_loadImageCommand.errors subscribeOn:[RACScheduler mainThreadScheduler]] map:^id(NSError *error) {
        return [NSNumber numberWithBool:NO];
    }];
    
    @weakify(self);
    [[[RACSignal merge:@[startedMessageSource, completedMessageSource, failedMessageSource]] deliverOnMainThread]subscribeNext:^(NSNumber *running) {
        @strongify(self);
        NSLog(@"%@", running);
        if([running boolValue]) {
            self.image = [UIImage imageNamed:@"frame-landscape-200"];
            self.contentMode = UIViewContentModeCenter;
        }
    }];
}

-(void) setImagePath:(NSString *)imagePath {
    if([imagePath isEqualToString:_imagePath]) {
        return;
    }
    if(_loadDisposable) {
        [_loadDisposable dispose];
    }
    _imagePath = imagePath;
    [_loadImageCommand execute:_imagePath];
}

-(void) dealloc {
    
}
@end
