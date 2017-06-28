//
//  SPVCreationModel.h
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/06/28.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>

@interface SPVCreationModel : RVMViewModel

@property (nonatomic, assign, readonly) NSInteger status;
@property (nonatomic, strong, readonly) NSString *accountId;
//@property (nonatomic, strong, readonly) NSString *accountId;

@property (nonatomic, readonly) RACSignal *updatedContentSignal;
@end
