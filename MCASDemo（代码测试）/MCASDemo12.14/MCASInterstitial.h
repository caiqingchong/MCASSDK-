

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>





@interface MCASInterstitial:NSObject


/**
 *  GPS广告定位开关,默认为关闭 [可选]GPS精准定位模式开关，YES为开启GPS，NO为关闭
 */
@property(nonatomic, assign) BOOL isGpsOn;


/**
 *  Banner构造方法
 *  frame是广告banner展示的位置和大小，包含四个参数(x, y, width, height)
 *  appID是应用id，slotID是广告位id
 */
- (instancetype)initWithAppID:(NSString *)appID slotID:(NSString *)slotID;

/**
 *  拉取广告
 */
- (void)loadInterstitial;

/**
 *  展示广告
    参数为要展现广告的View
 */
- (void)showInterstitial:(UIViewController*)parentView;

@end
