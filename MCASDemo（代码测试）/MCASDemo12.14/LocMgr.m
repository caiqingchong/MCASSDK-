//
//  LocMgr.m
//  banner
//
//  Created by leon on 15/12/8.
//  Copyright (c) 2015年 leon. All rights reserved.
//

#import "LocMgr.h"

@interface LocMgr(){

    CLLocationManager *locationMgr;
    
    NSString* latitude;
    NSString* longitude;
}
@end

@implementation LocMgr


+(LocMgr*)getInstance{
    static LocMgr *locMgr;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        locMgr = [[LocMgr alloc] initLocation];
    });

   return locMgr;
}
//这里适配了IOS8、9   但是用户的版本要与之对应才能使用
-(id)initLocation{
    self =[super init];
    
    if (self) {
        locationMgr = [[CLLocationManager alloc] init];
        locationMgr.delegate = self;
        [locationMgr requestAlwaysAuthorization];
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
        locationMgr.distanceFilter = kCLDistanceFilterNone;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&[[[UIDevice currentDevice] systemVersion] floatValue]<9.0){
            [locationMgr requestWhenInUseAuthorization];
        }else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            //locationMgr.allowsBackgroundLocationUpdates = YES;
        }
        
        [locationMgr startUpdatingLocation];
  
    }
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *cl = [locations objectAtIndex:0];
    latitude = [NSString stringWithFormat:@"%2f",cl.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%2f",cl.coordinate.longitude];
    [manager stopUpdatingLocation];
}


-(NSString*)getLatitude{
    
    return latitude;
}
-(NSString*)getLongitude{
    return longitude;
}




@end
