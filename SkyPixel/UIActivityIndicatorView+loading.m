//
//  UIActivityIndicatorView+loading.m
//  SkyPixel
//
//  Created by Xiangwei Wang on 2017/06/28.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "UIActivityIndicatorView+loading.h"

@implementation UIActivityIndicatorView (loading)

-(BOOL) loading {
    return [self isAnimating];
}

-(void) setLoading:(BOOL)loading {
    if(loading) {
        if([self isAnimating]) {
            return;
        }
        
        [self startAnimating];
    } else {
        if([self isAnimating]) {
            [self stopAnimating];
        }
    }
}
@end
