//
//  SWManger.h
//  SimpleWeather
//
//  Created by andy on 24/5/14.
//  Copyright (c) 2014 andy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "SWCondition.h"

@interface SWManager : NSObject<CLLocationManagerDelegate>

+(instancetype)sharedManager;

@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) SWCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

- (void)findCurrentLocation;

@end
