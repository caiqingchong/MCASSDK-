//
//  LocMgr.h
//  banner
//
//  Created by leon on 15/12/8.
//  Copyright (c) 2015年 leon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface LocMgr : NSObject <CLLocationManagerDelegate>

+(LocMgr*)getInstance;

-(NSString*)getLatitude;
-(NSString*)getLongitude;

@end
