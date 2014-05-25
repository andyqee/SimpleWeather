//
//  SWDaliyForcast.m
//  SimpleWeather
//
//  Created by andy on 24/5/14.
//  Copyright (c) 2014 andy. All rights reserved.
//

#import "SWDailyForecast.h"

@implementation SWDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // 1
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    // 2
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    // 3
    return paths;
}

@end
