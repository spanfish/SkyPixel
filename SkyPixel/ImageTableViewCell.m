//
//  ImageTableViewCell.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/30.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "ImageTableViewCell.h"
#import <ReactiveCocoa.h>

@implementation ImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setModel:(NSDictionary *)model {
    _model = model;
    
    self.locationLabel.text = @"";
    self.coverImageView.image = nil;
    self.equipLabel.text = @"";
    self.shutterLabel.text = @"";
    self.focusLabel.text = @"";
    
    //image
    NSString *imagePath = [_model objectForKey:@"image"];
    if([imagePath isKindOfClass:[NSString class]]) {
        imagePath = [imagePath stringByAppendingString:@"@!1200"];
        
        [[[[self loadImageWithURLString:imagePath]
           takeUntil:[self rac_prepareForReuseSignal]]
          deliverOnMainThread] 
         subscribeNext:^(UIImage *image) {
             self.coverImageView.image = image;
             self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
         }];
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
    
    if([latitude respondsToSelector:@selector(doubleValue)] && [longitude respondsToSelector:@selector(doubleValue)]) {
        @weakify(self)
        [[[[self signalForReverseGeocodeLatitude:[latitude doubleValue] longitude:[longitude doubleValue]]
           takeUntil:[self rac_prepareForReuseSignal]]
          deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self)
            self.locationLabel.text = x;
        }];
    }
    
    /*
    RAC(self.shutterLabel, text) = [[RACObserve(self, model)
                                     takeUntil:[self rac_prepareForReuseSignal]]
                                    map:^id(NSDictionary *value) {
                                        NSString *latitude = [value objectForKey:@"latitude"];
                                        NSString *longitude = [value objectForKey:@"longitude"];
                                        
                                        return @"";
                                    }];
     */
    //shutter
    RAC(self.shutterLabel, text) = [[RACObserve(self, model)
                                   takeUntil:[self rac_prepareForReuseSignal]]
                                  map:^id(NSDictionary *value) {
                                      NSString *shutter = [value objectForKey:@"shutter"];
                                      NSString *aperture = [value objectForKey:@"aperture"];
                                      
                                      return [NSString stringWithFormat:@"%@ %@", aperture == nil ? @"n/a" : [NSString stringWithFormat:@"f%@", aperture],
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
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
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
    }] subscribeOn:scheduler];
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