//
//  MACSInterstitial.m
//  bannerdemo
//
//  Created by leon on 15/12/9.
//  Copyright (c) 2015年 leon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCASInterstitial.h"
#import "Util.h"
#import "LocMgr.h"
#import "MCASExplore.h"
#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)

typedef enum{
    TestA = 0,
    TestB,
    TestC,
    TestD
    
}Test;


@interface MCASInterstitial()<UIWebViewDelegate,UIGestureRecognizerDelegate>{
    
    
    UIImage* image;
    UIImageView* imageView;
    NSString* appKey;
    NSString* slotKey;
    
    NSMutableArray *arrClickURL;
    NSMutableArray *arrTrackURL;
    int cli_type;
    MCASExplore *_webView;
    UIWebView *htmlWebView;
    int mType;
    NSString *m_html;
}
@end


@implementation MCASInterstitial : NSObject


- (instancetype)initWithAppID:(NSString *)appID slotID:(NSString *)slotID{
    
    self =[super init];
    
    if (self) {
        appKey = appID;
        slotKey = slotID;
        self.isGpsOn = false;
    }
    return self;

}

/**
 *  拉取广告
 */
- (void)loadInterstitial{
    NSString* strURL;
    if(self.isGpsOn){
        strURL = [Util getURLString:appKey slotKey:slotKey :[[LocMgr getInstance] getLongitude]  : [[LocMgr getInstance] getLatitude]];
    }
    else{
        strURL= [Util getURLString:appKey slotKey:slotKey :nil : nil];
    }
    
    
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
                NSLog(@"jsonData:%@",jsonDicData);
                arrClickURL = [[[jsonDicData objectForKey:@"adList"] objectAtIndex:0] objectForKey:@"click_url"];
                NSMutableArray *arrPicURL = [[[jsonDicData objectForKey:@"adList"] objectAtIndex:0] objectForKey:@"pic_url"];
                arrTrackURL = [[[jsonDicData objectForKey:@"adList"] objectAtIndex:0] objectForKey:@"track_url"];
                //判断到底用什么浏览器打开  整形数据
                cli_type = [[[[jsonDicData objectForKey:@"adList"]objectAtIndex:0] objectForKey:@"cli_type"] intValue];
                
                mType = [[[[jsonDicData objectForKey:@"adList"]objectAtIndex:0] objectForKey:@"m_type"] intValue];
                
                m_html = [[[jsonDicData objectForKey:@"adList"]objectAtIndex:0] objectForKey:@"m_html"];
                NSLog(@"MCAS: image url = %@",arrPicURL[0]);
                
                NSURL *url = [NSURL URLWithString:arrPicURL[0]];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                image = [UIImage imageWithData:imageData];
                
                NSLog(@"MCAS 图片加载成功.");
            }else{
           
                NSLog(@"MCAS 服务器返回数据不完整");
            }
            
        }else if([data length] == 0 && connectionError == nil){
            NSLog(@"MCAS 无数据返回");
        }else if(connectionError != nil){
            NSLog(@"MCAS 网络错误 returncode = %ld",connectionError.code);
        }
        
    }];

}

/**
 *  展示广告
 参数为要展现广告的View
 */
//在这里先加载完主线程，分线程还没有被加载完成，所以没有图片信息
- (void)showInterstitial:(UIViewController*)parentView{
    //内置浏览器
    _webView = [[MCASExplore alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    _webView.hidden = YES;
    
    htmlWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0 , 0.3*HEIGHT, WIDTH, 0.4*HEIGHT)];
    htmlWebView.delegate = self;

    if (1 == mType) {
        if(image){
            [htmlWebView removeFromSuperview];

            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0 , 0.3*HEIGHT, WIDTH, 0.4*HEIGHT)];
            imageView.image = image;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myimageClick)];
            [imageView addGestureRecognizer:tap];
            [imageView addSubview:[self getRemoveAdButtom]];
            [[parentView view ] addSubview:imageView];
            [Util sendURLs:arrTrackURL];
            
            [parentView.view addSubview:_webView];
        }
    }
    //html 物料  4 html片段  5  html URL  点击HTML里面的网址跳转到下个内置浏览器或者是系统浏览器
        if (4 == mType && m_html!= nil) {
        
        [imageView removeFromSuperview];

        [htmlWebView loadHTMLString:m_html baseURL:nil];
        [htmlWebView addSubview:[self getRemoveAdButtom]];
        [parentView.view addSubview:htmlWebView];
        //添加隐藏的内置浏览器
        [parentView.view addSubview:_webView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myimageClick)];
        tap.delegate = self;
        tap.cancelsTouchesInView = NO;
        [htmlWebView addGestureRecognizer:tap];

        
         [Util sendURLs:arrTrackURL];
    }
    if (5 == mType && m_html!= nil) {
        [imageView removeFromSuperview];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:m_html]];
        [htmlWebView loadRequest:request];
        [htmlWebView addSubview:[self getRemoveAdButtom]];
        [parentView.view addSubview:htmlWebView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myimageClick)];
        tap.delegate = self;
        tap.cancelsTouchesInView = NO;
        [htmlWebView addGestureRecognizer:tap];
        
        [Util sendURLs:arrTrackURL];
    }
}


//点击广告，调用系统打开路径相当于发送点击   判断调用系统的还是自写的浏览器
- (void)myimageClick{

    NSURL *url = [NSURL URLWithString:[arrClickURL objectAtIndex:0]];
    if (1 == cli_type) {
        _webView.hidden = NO;
//        _webView.delegate = self;
        [_webView openURL:url];
    
    }else{
        //跳转到AppStore下载数据
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (UIButton *)getRemoveButton{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeSystem];
    but.frame = CGRectMake(WIDTH-20,0, 20, 20);
    but.tag = 0;
    [but setBackgroundImage:[self getBundleImage:but.tag] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
    return but;
    
}

- (UIButton *)getRemoveAdButtom{

    UIButton *but = [UIButton buttonWithType:UIButtonTypeSystem];
    but.frame = CGRectMake(WIDTH-20, 0, 20, 20);
    but.tag = 0;
    [but setBackgroundImage:[self getBundleImage:but.tag] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(removeAdView) forControlEvents:UIControlEventTouchUpInside];
    return but;
}

- (UIImage *)getBundleImage:(NSInteger)sender{
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"mcasimage" ofType:@"bundle"];
    NSArray *arr = [[NSArray alloc]initWithObjects:@"Remove.png",@"back.png",@"forward.png",@"refresh", nil];
    //拼接路径，获取图片路径
    NSString *imagePath = [bundlePath stringByAppendingPathComponent:[arr objectAtIndex:sender]];
    UIImage *locationImage = [UIImage imageWithContentsOfFile:imagePath];
    return locationImage;
}

- (void)removeView{
    [_webView removeFromSuperview];
}
- (void)removeAdView{
    
    [imageView removeFromSuperview];
    if (mType==4 || mType==5) {
        [htmlWebView removeFromSuperview];
    }
}



#pragma make 手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
    
}

@end



