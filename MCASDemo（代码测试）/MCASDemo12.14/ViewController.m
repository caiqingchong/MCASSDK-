//
//  ViewController.m
//  MCASDemo12.14
//
//  Created by Apple on 15/12/14.
//  Copyright © 2015年 mcas. All rights reserved.
//

#import "ViewController.h"
#import "MCASBannerView.h"
#import "InsertViewController.h"

@interface ViewController ()<MCASBannerViewDelegate>

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"--------------RunLoop:%@",[NSRunLoop mainRunLoop]);

    MCASBannerView *banner = [[MCASBannerView alloc]initWithFrame:CGRectMake(0, 100, 320, 50) appID:@"09c4aaeb-2feb-45f0-b587-5d9e928157b8" slotID:@"568dd820-31ce-4940-8629-faf628d99f53"];
    banner.parentViewController = self;
    banner.delegate = self;
    [banner showBanner];
    
    UIButton *but =[UIButton buttonWithType:UIButtonTypeSystem];
    [but setTitle:@"chaping" forState:UIControlStateNormal];
    but.frame = CGRectMake(0, 200, 100, 40);
    [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    but.backgroundColor = [UIColor redColor];
    [but addTarget:self action:@selector(backUrl) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
     NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"-------获取：%@",app_Version);
}

- (void)backUrl{
    InsertViewController *insert = [[InsertViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:insert];
    self.view.window.rootViewController = nav;
}


/**
 *  拉取广告成功后回调
 */
- (void)bannerViewDidReceived{
    NSLog(@"拉取广告成功后回调");
}

/**
 *  拉取广告失败后回调
 */
- (void)bannerViewFailToReceived{
    NSLog(@"广告拉取失败回调");
}

/**
 *  广告曝光回调
 */
- (void)bannerExposured{
    NSLog(@"广告曝光回调");
}

/**
 *  广告点击回调
 */
- (void)bannerClicked{

    NSLog(@"广告点击回调");
}


//当出现内存警告时，需要手动将 self.view = nil,并且释放子视图
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.view = nil;
    
}

@end
