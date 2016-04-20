//
//  MCASBannerView.m
//  banner
//
//  Created by leon on 15/12/7.
//  Copyright (c) 2015年 leon. All rights reserved.
//  内置浏览器，前进后退刷新退出  退出放到上面，其余三个放到下面的导航条中

#import <Foundation/Foundation.h>

#import "MCASBannerView.h"
#import "Util.h"
#import "LocMgr.h"
#import "MCASExplore.h"

#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)


@interface MCASBannerView()<UIWebViewDelegate,UIGestureRecognizerDelegate>{
    

    UIImageView* bannerView;
    
    NSString* appKey;
    NSString* slotKey;
    
    UIWebView *htmlWebView;
    
    NSMutableArray *arrClickURL;
    
    int cli_type;
    MCASExplore *explore;
    NSTimer* timer;

}


@end


@implementation MCASBannerView
    
/**
 *  Banner构造方法
 *  frame是广告banner展示的位置和大小，包含四个参数(x, y, width, height)
 *  appID是应用id，slotID是广告位id
 */


- (instancetype) initWithFrame:(CGRect)frame appID:(NSString *)appID slotID:(NSString *)slotID{
    
    self =[super init];
    
    if (self) {
        bannerView = [[UIImageView alloc] initWithFrame:frame];
        [bannerView setTag:3321];

        self.isGpsOn = false;
        appKey = appID;
        slotKey = slotID;
            htmlWebView.delegate = self;
        htmlWebView = [[UIWebView alloc] initWithFrame:frame];
        [htmlWebView setTag:3322];
        
       }
    return self;
}


/**
 *  拉取并展示广告
 */
- (void) showBanner{
    if (self.adFreshInterval<10) {
        self.adFreshInterval = 10;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:self.adFreshInterval target:self selector:@selector(doIt) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [timer fire];
}



-(void)doIt{
    
    @autoreleasepool {
        
        
        NSString* strURL;
        if(self.isGpsOn){
            strURL = [Util getURLString:appKey slotKey:slotKey :[[LocMgr getInstance] getLongitude]  : [[LocMgr getInstance] getLatitude]];
        }
        else{
            strURL= [Util getURLString:appKey slotKey:slotKey :nil : nil];
        }
        //在这里获取拼接的网址，然后进行UTF8转码
        NSString* tmpStr = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:tmpStr];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
        [urlRequest setTimeoutInterval:5.0f];
        
        [urlRequest setHTTPMethod:@"GET"];

        NSOperationQueue *queue = [[NSOperationQueue alloc]init];

        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *  response, NSData * data, NSError * connectionError) {
  
            if ([data length] && connectionError == nil) {

                NSMutableDictionary *jsonDicData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
                if (jsonDicData != NULL && 200 == [[jsonDicData objectForKey:@"returncode"] integerValue] ) {
                    
                    [self.delegate bannerViewDidReceived];
                    int mType;
                    NSString *m_html;
 
                    arrClickURL = [[[jsonDicData objectForKey:@"adList"] objectAtIndex:0] objectForKey:@"click_url"];
                    
                    NSMutableArray *arrPicURL = [[[jsonDicData objectForKey:@"adList"] objectAtIndex:0] objectForKey:@"pic_url"];
                    
                    NSMutableArray *arrTrackURL = [[[jsonDicData objectForKey:@"adList"] objectAtIndex:0] objectForKey:@"track_url"];
                    
                    cli_type = [[[[jsonDicData objectForKey:@"adList"]objectAtIndex:0] objectForKey:@"cli_type"] intValue];

                    mType = [[[[jsonDicData objectForKey:@"adList"]objectAtIndex:0] objectForKey:@"m_type"] intValue];
                    
                    //物料
                    m_html = [[[jsonDicData objectForKey:@"adList"]objectAtIndex:0] objectForKey:@"m_html"];

                    //可以在主界面中进行判断
                    if(mType  == 1){
                        //图片,移除HTML视图,还要置空
                        [htmlWebView removeFromSuperview];
                        
                        NSURL *url = [NSURL URLWithString:arrPicURL[0]];
                        
                        NSData* imageData =  [NSData dataWithContentsOfURL:url];
                        
                        UIImage *uiImage = [UIImage imageWithData:imageData];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{

                            bannerView.image = uiImage;
                            [Util sendURLs:arrTrackURL];
                            [self.delegate bannerExposured];
                            
                            UIView* view=[[self.parentViewController view] viewWithTag:3321];
                            
                            if(view == nil){
                                
                                bannerView.userInteractionEnabled = YES;
                                
                                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick)];
                                
                                [bannerView addGestureRecognizer:tap];
                                [[self.parentViewController view] addSubview:bannerView];
                            }
                            
                        });
                    }else if(mType == 4 && m_html!= nil){
  
                        [bannerView removeFromSuperview];
                      
                        dispatch_async(dispatch_get_main_queue(), ^{

                        [htmlWebView loadHTMLString:
                         m_html baseURL:nil];
                        [self.parentViewController.view addSubview:htmlWebView];
                        [Util sendURLs:arrTrackURL];
                        [self.delegate bannerExposured];
                            
                        //添加事件点击之后调用代理
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getDelegate)];
                            tap.delegate = self;
                            tap.cancelsTouchesInView = NO;
                        [htmlWebView addGestureRecognizer:tap];
                        });
                    }else if(mType == 5 && m_html!= nil){
                        
                        [bannerView removeFromSuperview];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:m_html]];
                            [htmlWebView loadRequest:request];
                            [self.parentViewController.view addSubview:htmlWebView];
                            [Util sendURLs:arrTrackURL];
                            [self.delegate bannerExposured];

                            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getDelegate)];
                            tap.delegate = self;
                            tap.cancelsTouchesInView = NO;
                            [htmlWebView addGestureRecognizer:tap];
                        });
                        
                    }
                    
                }else{
                    //给个服务器错误通知
                    NSLog(@"MCAS 服务器返回信息不完整");
                    [self.delegate bannerViewFailToReceived];
                }
            
            }else if([data length] == 0 && connectionError == nil){
                [self.delegate bannerViewFailToReceived];

                NSLog(@"MCAS 无数据返回");
            }else if(connectionError != nil){
                
                NSLog(@"MCAS 网络错误 returncode = %ld",connectionError.code );
            }
        }];
    }
}

- (void)getDelegate{
    timer.fireDate = [NSDate distantFuture];
    [self imageClick];
    
}


//在这里会不会进行重复统计  在下面已经进行点击统计了
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //判断是HTML否存在

    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"started");
}


//点击广告，调用系统打开路径相当于发送点击  把路径传过去
- (void)imageClick{
    NSURL *url = [NSURL URLWithString:[arrClickURL objectAtIndex:0] ];
    [self.delegate bannerClicked];
    if (cli_type == 1) {
        explore = [[MCASExplore alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
        explore.delegate = self;
        [explore openURL:url];
        [self.parentViewController.view addSubview:explore];
     
    }else{
        [[UIApplication sharedApplication] openURL:url];
    }
}


#pragma make 手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{

    return YES;
    
}

//http://192.168.0.173:8083/mcas/testapi/q?sk=5ac5334a-830c-4d13-a1c3-bac6d3e17873&apk=09c4aaeb-2feb-45f0-b587-5d9e928157b8&adty=(null)&pn=com.mcas.MCASDemo12-14&an=MCASDemo12.14&cnn=1&car=0&mc=&idfa=D0CB94B5-B1EC-4559-9CFE-2EEEAAFE06B2&oid=&dv=iPhone&ua=&os=1&osv=9.000000&ln=(null)&lt=(null)&med=1&w=414.000000&h=736.000000




@end