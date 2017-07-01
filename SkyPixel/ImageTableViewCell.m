//
//  ImageTableViewCell.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "ImageTableViewCell.h"
#import <ReactiveCocoa.h>


@interface ImageTableViewCell()

@property(nonatomic, strong) NSDictionary *model;
@end

@implementation ImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) configureCellWithModel:(NSDictionary *) model {
    if(_model == model) {
        return;
    }
    _model = model;
    
    self.locationLabel.text = @"";
    self.coverImageView.image = nil;
    self.equipLabel.text = @"";
    self.shutterLabel.text = @"";
    self.focusLabel.text = @"";
    
    //image
    
    NSString *imagePath = [_model objectForKey:@"image"];
//    NSMutableArray *images = [NSMutableArray arrayWithCapacity:6];
//    for(NSInteger i = 0; i < 6; i++) {
//        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"propeller_horizon_%ld", i * 30]]];
//    }
    
    
//    self.coverImageView.animationImages = images;
//    [self.coverImageView startAnimating];
//    self.coverImageView.contentMode = UIViewContentModeCenter;
    
    if([imagePath isKindOfClass:[NSString class]]) {
        imagePath = [imagePath stringByAppendingString:@"@!1200"];
        
        self.coverImageView.imagePath = imagePath;
    } else {
        self.coverImageView.imagePath = nil;
    }
    
    RAC(self.equipLabel, text) = [[RACObserve(self, model)
                                      takeUntil:[self rac_prepareForReuseSignal]]
                                     map:^id(NSDictionary *value) {
                                         NSDictionary *dict = [value objectForKey:@"show_equipment"];
                                         NSString *equip = [dict objectForKey:@"name"];
                                         if([equip isKindOfClass:[NSString class]] && equip != nil) {
                                             return equip;
                                         } else {
                                             return @"";
                                         }
                                     }];
    //location
    NSString *latitude = [_model objectForKey:@"latitude"];
    NSString *longitude = [_model objectForKey:@"longitude"];
    self.locationLabel.text = @"n/a";
    if([latitude respondsToSelector:@selector(doubleValue)] && [longitude respondsToSelector:@selector(doubleValue)]) {
        @weakify(self)
        [[[[self signalForReverseGeocodeLatitude:[latitude doubleValue] longitude:[longitude doubleValue]]
           takeUntil:[self rac_prepareForReuseSignal]]
          deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self)
            self.locationLabel.text = x;
        }];
    }
    
    //shutter
    RAC(self.shutterLabel, text) = [[RACObserve(self, model)
                                   takeUntil:[self rac_prepareForReuseSignal]]
                                  map:^id(NSDictionary *value) {
                                      NSString *shutter = [value objectForKey:@"shutter"];
                                      NSString *aperture = [value objectForKey:@"aperture"];
                                      if([shutter isKindOfClass:[NSNull class]] || [shutter isEqualToString:@"<null>"]) {
                                          shutter = nil;
                                      }
                                      if([aperture isKindOfClass:[NSNull class]] ||[aperture isEqualToString:@"<null>"]) {
                                          aperture = nil;
                                      }
                                      return [NSString stringWithFormat:@"%@ %@", aperture == nil ? @"n/a" : [NSString stringWithFormat:@"%@%@", [aperture length] == 0 ? @"" : @"f", ([aperture length] > 2 ? [aperture substringToIndex:3]: aperture)],
                                              shutter == nil ? @"n/a" : shutter];
                                  }];
    //focus
    RAC(self.focusLabel, text) = [[RACObserve(self, model)
                                     takeUntil:[self rac_prepareForReuseSignal]]
                                    map:^id(NSDictionary *value) {
                                        NSNumber *focus = [value objectForKey:@"focal_length"];
                                        return [NSString stringWithFormat:@"%@", focus == nil ? @ "n/a" : [focus stringValue]];
                                    }];
}

-(RACSignal *) loadImageWithURLString:(NSString *) urlString {
    RACScheduler *scheduler = [RACScheduler
                               schedulerWithPriority:RACSchedulerPriorityBackground];
    RACSignal *sig =  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSData *data = nil;
        NSString *fileName = [urlString lastPathComponent];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:fileName];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            data = [NSData dataWithContentsOfFile:path];
        }
        
        if(!data) {
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            if(data) {
                [data writeToFile:path atomically:YES];
            }
        }
        
        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];

        return nil;
    }];
    [sig subscribeOn:scheduler];
    [sig logAll];
    return sig;
}

-(RACSignal *) signalForReverseGeocodeLatitude:(double) latitude longitude:(double) longitude {
    RACScheduler *scheduler = [RACScheduler
                               schedulerWithPriority:RACSchedulerPriorityBackground];
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        CLGeocoder *ceo = [[CLGeocoder alloc]init];
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];

        [ceo reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            for(CLPlacemark *placemark in placemarks) {
                if(placemark) {
                    NSString *locatedAt = [NSString stringWithFormat:@"%@ %@ %@",
                                           placemark.administrativeArea ? placemark.administrativeArea : @"" ,
                                           placemark.locality ? placemark.locality : @"",
                                           placemark.subLocality ? placemark.subLocality : @""];
//                    NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
//                    NSLog(@"placemark %@",placemark.region);
//                    NSLog(@"placemark %@",placemark.country);  // Give Country Name
//                    NSLog(@"placemark %@",placemark.locality); // Extract the city name
//                    NSLog(@"location %@",placemark.name);
//                    NSLog(@"location %@",placemark.ocean);
//                    NSLog(@"location %@",placemark.postalCode);
//                    NSLog(@"location %@",placemark.subLocality);
//                    
//                    NSLog(@"location %@",placemark.location);
//                    //Print the location to console
//                    NSLog(@"I am currently at %@",locatedAt);
                    [subscriber sendNext:locatedAt];
                    [subscriber sendCompleted];
                    break;
                }
            }
        }];
        
        return nil;
    }] subscribeOn:scheduler];
}
@end
