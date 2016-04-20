

#import <Foundation/Foundation.h>


#import <UIKit/UIKit.h>

@protocol MCASBannerViewDelegate <NSObject>

@optional

/**
 *  拉取广告成功后回调
 */
- (void)bannerViewDidReceived;

/**
 *  拉取广告失败后回调
 */
- (void)bannerViewFailToReceived;

/**
 *  广告曝光回调
 */
- (void)bannerExposured;

/**
 *  广告点击回调
 */
- (void)bannerClicked;

@end


@interface MCASBannerView : UIView

/**
 *  父视图  [必选]需设置为显示广告的UIViewController
 */
@property (nonatomic, weak) UIViewController *parentViewController;

/**
 *  广告刷新间隔 [可选] //默认10秒
 */
@property(nonatomic, assign) int adFreshInterval;

/**
 *  GPS广告定位开关,默认为关闭 [可选]GPS精准定位模式开关，YES为开启GPS，NO为关闭
 */
@property(nonatomic, assign) BOOL isGpsOn;


/**
 *  Banner构造方法
 *  frame是广告banner展示的位置和大小，包含四个参数(x, y, width, height)
 *  appID是应用id，slotID是广告位id
 */
- (instancetype) initWithFrame:(CGRect)frame appID:(NSString *)appID slotID:(NSString *)slotID;

/**
 *  拉取并展示广告
 */
- (void) showBanner;

@property (nonatomic,weak) id<MCASBannerViewDelegate> delegate;

@end
