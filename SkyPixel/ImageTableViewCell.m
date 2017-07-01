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
                                         NSString *model = [value objectForKey:@"model"];
                                         NSString *dji_equipment = [dict objectForKey:@"dji_equipment"];
                                         
                                         if([equip isKindOfClass:[NSString class]] && equip != nil) {
                                             return equip;
                                         } else {
                                             if([dji_equipment isKindOfClass:[NSString class]] && dji_equipment != nil) {
                                                 return dji_equipment;
                                             } else {
                                                 if([model isKindOfClass:[NSString class]] && model != nil) {
                                                     return model;
                                                 } else {
                                                     return @"n/a";
                                                 }
                                             }
                                         }
                                     }];
    //location
    NSString *latitude = [_model objectForKey:@"latitude"];
    NSString *longitude = [_model objectForKey:@"longitude"];
    self.locationLabel.text = @"n/a";
    if([latitude respondsToSelector:@selector(doubleValue)] && [longitude respondsToSelector:@selector(doubleValue)]) {
        @weakify(self)
        self.locationLabel.text = [NSString stringWithFormat:@"lat:%@, lon:%@", latitude, longitude];
        if(CLLocationCoordinate2DIsValid(CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]))) {
            [[[[self signalForReverseGeocodeLatitude:[latitude doubleValue] longitude:[longitude doubleValue]]
               takeUntil:[self rac_prepareForReuseSignal]]
              deliverOnMainThread] subscribeNext:^(NSString *address) {
                @strongify(self)
                self.locationLabel.text = address == nil ? @"n/a" : address;
            }];

        }
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
                    if([[locatedAt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
                        NSArray *address = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
                        if([address count] > 0) {
                            locatedAt = [address componentsJoinedByString:@" "];
                        }
                    }
                    NSLog(@"location:%@", locatedAt);
                    [subscriber sendNext:locatedAt];
                    //[subscriber sendCompleted];
                    break;
                }
            }
        }];
        
        return nil;
    }] subscribeOn:scheduler];
}
@end
