//
//  Util.m
//  CoopenTest
//
//  Created by Apple on 15/12/6.
//  Copyright © 2015年 mcas. All rights reserved.

//  这里进行所有的网络请求的拼接

#import "Util.h"


#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)

@implementation Util


+ (NSString *)getURLString:(NSString*)appKey slotKey:(NSString*)slotKey :(NSString*)longtitude :(NSString*)latitude{
    
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    NSString *idfa= [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *osvStr = [NSString stringWithFormat:@"%f",[[[UIDevice currentDevice] systemVersion] floatValue]];
    
    NSString *dv = [[UIDevice currentDevice] model];
    NSString* netType = [self networktype];
    NSString* _car = [self getCarrierName];
    
    NSString* adType;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.mcas.com.cn/mcas/api/q?sk=%@&apk=%@&adty=%@&pn=%@&an=%@&cnn=%@&car=%@&mc=&idfa=%@&oid=&dv=%@&ua=&os=1&osv=%@&ln=%@&lt=%@&med=1&w=%f&h=%f",slotKey,appKey,adType,identifier,app_Name,netType,_car,idfa,dv,osvStr,longtitude,latitude,WIDTH,HEIGHT];
   
    NSLog(@"MCAS: ----网络请求%@",urlString);
    
    return urlString;
    
}

+(NSString* )networktype{
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    NSNumber *dataNetworkItemView = nil;
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    NSString* _netType;
    switch ([[dataNetworkItemView valueForKey:@"dataNetworkType"]integerValue]) {
            
        case 0:
            _netType = @"0";
            
            break;
        case 1:
            _netType = @"2";
            break;
        case 2:
            _netType = @"3";
            
            break;
        case 3:
            _netType = @"4";
            
            break;
        case 4:
            _netType = @"5";
            break;
        case 5:
            _netType = @"1";
            break;
        default:
            break;
    }
    
    return _netType;
}
//用户移动运营商
+ (NSString*)getCarrierName
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString * mcc = [carrier mobileCountryCode];
    NSString * mnc = [carrier mobileNetworkCode];
    if (mnc == nil || mnc.length <1 || [mnc isEqualToString:@"SIM Not Inserted"] ) {
        return @"0";
    }else { //移动联通电信铁通1234，未知为0
        if ([mcc isEqualToString:@"460"]) {
            NSInteger MNC = [mnc intValue];
            switch (MNC) {
                case 00:
                case 02:
                case 07:
                    return @"1";
                    //return @"China Mobile";
                    break;
                case 01:
                case 06:
                    return @"2";
                    //return @"China Unicom";
                    break;
                case 03:
                case 05:
                    return @"3";
                    //return @"China Telecom";
                    break;
                case 20:
                    return @"4";
                    //return @"China Tietong";
                    break;
                default:
                    break;
            }
        }
    }
    return @"0";
    
}

+(void)sendURLs:(NSMutableArray*)urls{
    
    for(int i = 0 ; i < [urls count];i++){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            
            NSString* tmpStr = [urls[i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:tmpStr];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            
            [urlRequest setTimeoutInterval:15.0f];
            [urlRequest setHTTPMethod:@"GET"];
            
            NSError* error = [[NSError alloc] init];
            NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] init];
            [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
            //如果是跳转则进行重复跳转发送 跳转语句通常设置301或者302  只需要跳转一次即可
            
            if (302 == response.statusCode || 301 == response.statusCode) {
                NSURL *url = response.URL;
                NSMutableURLRequest *redirectUrlRequest = [NSMutableURLRequest requestWithURL:url];
                [redirectUrlRequest setTimeoutInterval:15.0f];
                [redirectUrlRequest setHTTPMethod:@"GET"];
                NSError* error = [[NSError alloc] init];
         
                [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
            }
            
            NSLog(@"MCAS: Tracking URL invoked %@ , return code is %ld ",urls[i],error.code);
            
        });
    }
}


@end
