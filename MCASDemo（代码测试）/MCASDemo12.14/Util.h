//
//  Util.h
//  CoopenTest
//
//  Created by Apple on 15/12/6.
//  Copyright © 2015年 mcas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <netinet/in.h>



#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <AdSupport/AdSupport.h>


@interface Util : NSObject

+(void)sendURLs:(NSMutableArray*)urls;
+ (NSString *)getURLString:(NSString*)appKey slotKey:(NSString*)slotKey :(NSString*)longtitude :(NSString*)latitude;

@end
