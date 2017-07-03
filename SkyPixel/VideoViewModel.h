//
//  VideoViewModel.h
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/07/03.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>
#import <ReactiveCocoa.h>

@interface VideoViewModel : RVMViewModel {
    RACDisposable *_disposable;
}

@property(nonatomic, strong) NSString *URL;
@property(nonatomic, strong) RACSubject *videoDefinitionsSignal;
@property(nonatomic, strong) NSArray *videoDefinitions;
@property(nonatomic, assign) NSUInteger playingIndex;
@end
