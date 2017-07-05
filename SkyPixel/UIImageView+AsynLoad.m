//
//  UIImageView+AsynLoad.m
//  AsycImageExample
//
//  Created by xiangwei wang on 2017/07/03.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import "UIImageView+AsynLoad.h"
#import <ReactiveCocoa.h>

@implementation UIImageView (AsynLoad)

-(void) loadImage:(NSString *) imageURL forCell:(id)cell {
    if(![cell isKindOfClass:[UITableViewCell class]] && ![cell isKindOfClass:[UICollectionViewCell class]]) {
        NSAssert(NO, @"only UITableViewCell and UICollectionViewCell are supported");
        return;
    }
    self.image = nil;
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [cachePath stringByAppendingPathComponent:[imageURL lastPathComponent]];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.image = [UIImage imageWithContentsOfFile:filePath];
        [self notifyImageDidLoadToCell: cell];
        return;
    }
    
    self.animationImages = @[
                             [UIImage imageNamed:@"more"],
                             [UIImage imageNamed:@"more_loading_1"],
                             [UIImage imageNamed:@"more_loading_2"],
                             [UIImage imageNamed:@"more_loading_3"]
                             ];
    self.animationDuration = 1.2;
    self.contentMode = UIViewContentModeCenter;
    [self startAnimating];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
    @weakify(self);
    [[[[NSURLConnection rac_sendAsynchronousRequest: request]
      takeUntil:[cell rac_prepareForReuseSignal]]
      deliverOnMainThread]
     subscribeNext:^(RACTuple * _Nullable tuple) {
         @strongify(self);
         NSData *imageData = [tuple second];
         self.image = [UIImage imageWithData:imageData];
         [self notifyImageDidLoadToCell:cell];
         [self hideLoading];

         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
             [imageData writeToFile:[cachePath stringByAppendingPathComponent:[imageURL lastPathComponent]] atomically:YES];
         });
     } error:^(NSError *error) {
         [self hideLoading];
         [self notifyImageDidLoadToCell:cell];
     }];
}

-(void) hideLoading {
    [self stopAnimating];
    self.animationImages = nil;
}

-(void) notifyImageDidLoadToCell:(id) cell {
    self.contentMode = UIViewContentModeScaleAspectFill;
    if([cell respondsToSelector:@selector(imageDidLoad:)]) {
        [cell performSelectorOnMainThread:@selector(imageDidLoad:) withObject:self.image waitUntilDone:NO];
    }
}
@end
