//
//  SWManger.m
//  SimpleWeather
//
//  Created by andy on 24/5/14.
//  Copyright (c) 2014 andy. All rights reserved.
//

#import "SWManager.h"
#import "SWClient.h"
#import <TSMessages/TSMessage.h>
@interface SWManager()

@property (nonatomic, strong, readwrite) SWCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) SWClient *client;

@end

@implementation SWManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _client = [[SWClient alloc] init];
        [[[[RACObserve(self, currentLocation) ignore:nil]
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];
           }] deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error"
                                         subtitle:@"There was a problem fetching the latest weather."
                                             type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}

- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    CLLocation *location = [locations lastObject];
    
    if (location.horizontalAccuracy > 0) {
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

- (RACSignal *)updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(SWCondition *condition) {
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast {
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
    }];
}

- (RACSignal *)updateDailyForecast {
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecast = conditions;
    }];
}

@end
