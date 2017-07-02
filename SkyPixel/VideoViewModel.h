//
//  VideoViewModel.h
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/07/02.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "RVMViewModel.h"
#import <ReactiveObjc/ReactiveObjC.h>

@interface VideoViewModel : RVMViewModel {
    RACDisposable *_disposable;
}

@property(nonatomic, strong) NSString *URL;
@property(nonatomic, strong) RACSubject *videoURLSignal;
@property(nonatomic, strong) NSArray *videoDefinitions;
@property(nonatomic, assign) NSUInteger playingIndex;
@end
