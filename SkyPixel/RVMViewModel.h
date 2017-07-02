//
//  RVMViewModel.h
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/07/02.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjc/ReactiveObjC.h>

@interface RVMViewModel : NSObject

@property(nonatomic, strong) id model;
@property(nonatomic, assign) BOOL active;
@property(nonatomic, strong) RACSignal* didBecomeActiveSignal;
-(instancetype) initWithModel:(id)model;
@end
