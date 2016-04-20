//
//  MCASSplashAd.m
//  CoopenTest
//
//  Created by Apple on 15/12/5.
//  Copyright © 2015年 mcas. All rights reserved.
//  webView 不能放到window上面，否则广告时间到了之后就会直接进入主界面中去了

#import "MCASSplashAd.h"
#import "Util.h"
#import "LocMgr.h"
#import <CoreLocation/CoreLocation.h>

#define MCAS_CACHE_PIC_URL "mcs_cache_pic_url"
#define MCAS_CACHE_TRACKING_URL "mcs_cache_tracking_url"
#define MCAS_CACHE_CLICK_URL "mcs_cache_click_url"
#define MCAS_CACHE_TIMESTAMP "mcs_cache_time_stamp"
#define MCAS_CACHE_IMG_DATA "mcs_cache_img_data"
#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface MCASSplashAd ()<CLLocationManagerDelegate,NSURLConnectionDataDelegate>{
    
    NSString *_slot_key,*_app_key;
    NSTimer *timer;
}

@end

@implementation MCASSplashAd


//发送key
-(id)initWithAppkey:(NSString *)appID slotID:(NSString *)slotID{
    
    if(self = [super init]){
        self.showSkipBtn = false;
        self.splashKeepLiveTime = 3;
        self.showLocation = false;
        _slot_key = slotID;
        _app_key = appID;
    }
    
    return self;
    
}
//在这里直接进行网络请求  获取数据创建线程进行解析  然后获取数据进行展示  在判断出现的各种情况
-(void)loadAdAndShowInWindow:(UIWindow *)window offset:(int)offset UserUIImage:(UIImage *)image{

    UIViewController* splashVC = [[UIViewController alloc] init];
    //发送路径请求数据时要在分线程中处理并且设置线程休眠，否则无法获取位置代理中的经纬度
    NSString* strURL= [Util getURLString:_app_key slotKey:_slot_key :nil:nil];

    NSString* tmpStr = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:tmpStr];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];

    [urlRequest setTimeoutInterval:5.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *  response, NSData * data, NSError * connectionError) {

        if ([data length] && connectionError == nil) {
  
            NSMutableDictionary *jsonDicData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
         
            if (jsonDicData != NULL &&  200 == [[jsonDicData objectForKey:@"returncode"]integerValue]) {
                
                NSMutableArray *arrClickURL = [[[jsonDicData objectForKey:@"adList"] objectAtIndex:0] objectForKey:@"click_url"];
                NSMutableArray *arrPicURL = [[[jsonDicData objectForKey:@"adList"] objectAtIndex:0] objectForKey:@"pic_url"];
                NSMutableArray *arrTrackURL = [[[jsonDicData objectForKey:@"adList"] objectAtIndex:0] objectForKey:@"track_url"];
           
                NSLog(@"MCAS: image url = %@",arrPicURL[0]);
                //获取缓存
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSString *cachedPicUrl = [ user objectForKey:@MCAS_CACHE_PIC_URL];
                if(cachedPicUrl != NULL){
                    NSString *strTimeStamp = [ user objectForKey:@MCAS_CACHE_TIMESTAMP];
                    NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
                    //时间标记也是实时更新的，记录上一次更新时间和这一次的时间进行对比，如果用户每天打开或者在设置的时间内打开那么就不会删除存储的数据
                    NSDate* dateTimeStamp=[formatter dateFromString:strTimeStamp];
                    
                    NSDate *now = [NSDate date];
                    
                    NSTimeInterval timeIntervalBetween = [now timeIntervalSinceDate:dateTimeStamp];
                    NSLog(@"获取时间差为：%lf",timeIntervalBetween);
                    
                    double standTimeInterval = 24*60*60*5;
                    //缓存小于5天则展示
                    if( timeIntervalBetween < standTimeInterval) {
                        
                        NSMutableArray *cacheTrackingURLs = [user objectForKey:@MCAS_CACHE_TRACKING_URL];
                        NSMutableArray *cacheClickURLs = [user objectForKey:@MCAS_CACHE_CLICK_URL];
                        NSData* cachedImgData = [user objectForKey:@MCAS_CACHE_IMG_DATA];
                        
                        if(cacheTrackingURLs && cacheClickURLs &&cachedImgData){
                            dispatch_sync(dispatch_get_main_queue(), ^{
    
                                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-offset)];
                                imageView.image = [UIImage imageWithData:cachedImgData];
                                
                                if (self.showSkipBtn) {
                                    [imageView addSubview:[self getJumpButton]];
                                }
                                
                                if(image != nil){
                                    UIImageView *userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, HEIGHT-offset, WIDTH, offset)];
                                    userImageView.image = image;
                                    [splashVC.view addSubview:userImageView];
                                }
                                
                                [[splashVC view] addSubview:imageView];
                                imageView.userInteractionEnabled = YES;
                                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick)];
                                [imageView addGestureRecognizer:tap];
                                window.rootViewController = splashVC;
                                [window makeKeyAndVisible];
            
                                timer = [NSTimer scheduledTimerWithTimeInterval:self.splashKeepLiveTime target:self selector:@selector(doFinish) userInfo:nil repeats:NO];
                                
                                [Util sendURLs:cacheTrackingURLs];
                                //这里是在window上面展示的，所以在还没有出现微博view的时候，界面就已经跳转到主界面了。
                          
                            });
                        }else{
                            NSLog(@"MCAS:没有拿到缓存信息.");
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                UIViewController* splashVC = [[UIViewController alloc] init];
                                window.rootViewController = splashVC;
                                [window makeKeyAndVisible];
                                [self.delegate showMainView];
                            });
                        }
                        
                    }else{
                    //时间过期，直接跳转到主界面
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            NSLog(@"MCAS 缓存图片过期");
                            UIViewController* splashVC = [[UIViewController alloc] init];
                            window.rootViewController = splashVC;
                            [window makeKeyAndVisible];
                            [self.delegate showMainView];
                        });
                }
                }else{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSLog(@"MCAS 没有缓存图片");
                        UIViewController* splashVC = [[UIViewController alloc] init];
                        window.rootViewController = splashVC;
                        [window makeKeyAndVisible];
                        [self.delegate showMainView];
                    });
                }
                
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                       
                        //缓存图片信息
                        NSURL *url = [NSURL URLWithString:arrPicURL[0]];
                        NSData *imageData = [NSData dataWithContentsOfURL:url];
                        //进行图片缓存
                        [user setObject:imageData forKey:@MCAS_CACHE_IMG_DATA];
                        NSArray * arrClickUrls = [NSArray arrayWithArray:arrClickURL];
                        NSString * picUrl = arrPicURL[0];
                        NSArray * arrTrackingUrls = [NSArray arrayWithArray:arrTrackURL];
                        //获取当前时间
                        NSDate *cacheDate = [NSDate date];
                        NSDateFormatter* cacheDateFormatter=[[NSDateFormatter alloc] init];
                        [cacheDateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
                        NSString *destDateString = [cacheDateFormatter stringFromDate:cacheDate];
                        
                        [user setObject:arrClickUrls forKey:@MCAS_CACHE_CLICK_URL];
                        [user setObject:picUrl forKey:@MCAS_CACHE_PIC_URL];
                        [user setObject:arrTrackingUrls forKey:@MCAS_CACHE_TRACKING_URL];
                        [user setObject:destDateString forKey:@MCAS_CACHE_TIMESTAMP];
                        
                        [user synchronize];
                    });
            
                
            }else{
                //给个服务器错误通知 服务器返回错误
                NSLog(@"MCAS 服务返回数据不完整");
                dispatch_sync(dispatch_get_main_queue(), ^{
                    UIViewController* splashVC = [[UIViewController alloc] init];
                    window.rootViewController = splashVC;
                    [window makeKeyAndVisible];
                    [self.delegate showMainView];
                });
            }
            
        }else if([data length] == 0 && connectionError == nil){
                //都要给个代理  服务器崩溃的情况
                NSLog(@"MCAS 无数据返回,服务器崩溃");
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIViewController* splashVC = [[UIViewController alloc] init];
                window.rootViewController = splashVC;
                [window makeKeyAndVisible];
                [self.delegate showMainView];
            });
          
        }else if(connectionError != nil){
                NSLog(@"MCAS 网络错误 returncode = %ld",connectionError.code);
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIViewController* splashVC = [[UIViewController alloc] init];
                window.rootViewController = splashVC;
                [window makeKeyAndVisible];
                [self.delegate showMainView];
            });
        }
    }];
    
}

//开屏的不能用用
-(void)imageClick{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *string = [[user objectForKey:@MCAS_CACHE_CLICK_URL] objectAtIndex:0];
    NSURL *url = [NSURL URLWithString:string];
  
    [[UIApplication sharedApplication] openURL:url];
 

}

//添加跳转按钮
- (UIButton *)getJumpButton{
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeSystem];
    but.frame = CGRectMake(WIDTH-50, 20, 40, 25);
    [but setTitle:@"跳过" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    but.backgroundColor = [UIColor clearColor];
    [but addTarget:self action:@selector(butClick) forControlEvents:UIControlEventTouchUpInside];
    return but;
}

- (void)butClick{
    
    [self.delegate showMainView];
}
//展示完成，定时器终止，调用代理
- (void)doFinish{
    [timer invalidate];
    timer = nil;
    if(self.delegate){
        [self.delegate showMainView];
    }
}
-(void)StopTimer{
    [timer invalidate];
    timer = nil;
}


- (UIImage *)getBundleImage{
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"mcasimage" ofType:@"bundle"];
    //拼接路径，获取图片路径
    NSString *imagePath = [bundlePath stringByAppendingPathComponent:@"Remove.png"];
    UIImage *locationImage = [UIImage imageWithContentsOfFile:imagePath];
    return locationImage;
}

@end
