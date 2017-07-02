//
//  SPVDetailModel.h
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <ReactiveObjC/ReactiveObjC.h>
#import "RVMViewModel.h"

@interface SPVDetailModel : RVMViewModel

@property (nonatomic, readonly) RACSignal *updatedContentSignal;

@property (nonatomic, readonly) NSDictionary *imageInfo;
@property (nonatomic, readonly) NSMutableArray *commentArray;
@property (nonatomic, readonly) NSMutableArray *relatedArray;
@property (nonatomic, readonly) NSMutableArray *alsoLikeArray;
@end
