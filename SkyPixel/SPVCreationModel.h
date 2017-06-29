//
//  SPVCreationModel.h
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/06/28.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>

@interface SPVCreationModel : RVMViewModel

@property (nonatomic, strong, readonly) NSArray *items;

@property (nonatomic, readonly) RACSignal *updatedContentSignal;
@end
