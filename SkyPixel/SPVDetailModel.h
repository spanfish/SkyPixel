//
//  SPVDetailModel.h
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>

@interface SPVDetailModel : RVMViewModel

@property (nonatomic, readonly) RACSignal *updatedContentSignal;
@property (nonatomic, readonly) NSDictionary *modelData;
@end
