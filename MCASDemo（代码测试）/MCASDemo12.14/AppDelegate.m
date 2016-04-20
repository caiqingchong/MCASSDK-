//
//  AppDelegate.m
//  MCASDemo12.14
//
//  Created by Apple on 15/12/14.
//  Copyright © 2015年 mcas. All rights reserved.
//

#import "AppDelegate.h"
#import "MCASSplashAd.h"
#import "ViewController.h"
@interface AppDelegate ()<MCASSplashAdDelegate>{
    MCASSplashAd *splash;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    splash = [[MCASSplashAd alloc]initWithAppkey:@"09c4aaeb-2feb-45f0-b587-5d9e928157b8" slotID:@"5ac5334a-830c-4d13-a1c3-bac6d3e17873"];
    splash.showSkipBtn = YES;
    splash.delegate = self;
    [splash loadAdAndShowInWindow:self.window offset:0 UserUIImage:nil];
    
    
    return YES;
}

-(void)showMainView{
    //直接在这里终止定时器防止出现的跳过之后，出现的界面闪的问题 （又重新加载界面）
    [splash StopTimer];
    
    ViewController *myview = [[ViewController alloc]init];
    myview.title = @"主界面";
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:myview];
    self.window.rootViewController = nav;
    
}

//非活动状态，保存UI状态
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"applicationWillResignActive非活动状态");
    
    
}
//进入后台保存用户数据释放资源
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground进入后台");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     NSLog(@"applicationWillEnterForeground应用进入到前台，用于恢复数据");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive应用进入前台并处于活动状态时调用方法并发出通知");

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate应用被终止时调用该方法");
}

@end
