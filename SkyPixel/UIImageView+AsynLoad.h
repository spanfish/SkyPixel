//
//  UIImageView+AsynLoad.h
//  AsycImageExample
//
//  Created by xiangwei wang on 2017/07/03.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (AsynLoad)

-(void) loadImage:(NSString *) imageURL forCell:(id)cell;
@end
