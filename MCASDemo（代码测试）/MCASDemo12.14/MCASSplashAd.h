//
//  MCASSplashAd.h
//  CoopenTest
//
//  Created by Apple on 15/12/5.
//  Copyright © 2015年 mcas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCASSplashAdDelegate <NSObject>

@required

/*
 *   展示主界面
 */
-(void)showMainView;

@end


@interface MCASSplashAd : NSObject


@property (nonatomic, weak) id<MCASSplashAdDelegate>delegate;

//是否添加跳过按钮，默认关闭
@property(nonatomic, assign) BOOL showSkipBtn;

//是否获取地理信息，默认关闭
@property (nonatomic, assign) BOOL showLocation;

//开屏持续时间,默认3秒
@property (nonatomic, assign) int splashKeepLiveTime;


//初始化 传入appID和广告位id
-(id)initWithAppkey:(NSString *)appID slotID:(NSString *)slotID;

/*
        展示开屏广告 offset:开屏底部预留高度 image:用户自定义开屏底部图片
        如果全屏展示，offset传0 ; image传nil
 */
-(void)loadAdAndShowInWindow:(UIWindow *)window offset:(int)offset UserUIImage:(UIImage *)image;

- (void)StopTimer;
@end
