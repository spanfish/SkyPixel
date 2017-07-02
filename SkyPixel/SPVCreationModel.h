//
//  SPVCreationModel.h
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/06/28.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

//#import <ReactiveViewModel/ReactiveViewModel.h>
#import "RVMViewModel.h"
#import <ReactiveObjc/ReactiveObjc.h>

@interface SPVCreationModel : RVMViewModel

@property (nonatomic, readonly) RACCommand *fetchContentCommand;

-(instancetype) init;

-(NSDictionary *) pages;
@end
