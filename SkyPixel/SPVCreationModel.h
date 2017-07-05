//
//  SPVCreationModel.h
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/06/28.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>
#import <ReactiveCocoa.h>

@interface SPVCreationModel : RVMViewModel

@property (nonatomic, readonly) RACCommand *fetchContentCommand;
@property (nonatomic, readonly) RACSubject *contentUpdatedSignal;
-(instancetype) init;

-(void) configureDefault;
-(NSDictionary *) pages;
@end
