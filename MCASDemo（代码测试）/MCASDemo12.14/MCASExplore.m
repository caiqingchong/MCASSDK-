//
//  MCASExplore.m
//  MCASDemo12.14
//
//  Created by Apple on 15/12/16.
//  Copyright © 2015年 mcas. All rights reserved.
//

#import "MCASExplore.h"
#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface MCASExplore ()<UIWebViewDelegate>

@end

@implementation MCASExplore


- (void)openURL:(NSURL *)url{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSLog(@"获取的路径是：%@",url);
    self.delegate = self;
    [self loadRequest:request];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [webView addSubview:[self getRemoveButton]];
    [self threeButton];
}

- (UIButton *)getRemoveButton{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeSystem];
    but.frame = CGRectMake(WIDTH-20, 20, 20, 20);
    but.tag = 0;
    [but setBackgroundImage:[self getBundleImage:but.tag] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(moveWebview) forControlEvents:UIControlEventTouchUpInside];
    return but;
    
}

- (void)moveWebview{
    [self removeFromSuperview];
}

- (void)threeButton{
    
    UIView *allView = [[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT-64-40, WIDTH, 40)];
    allView.backgroundColor = [UIColor whiteColor];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    back.tag = 1;
    [back setBackgroundImage:[self getBundleImage:back.tag] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    back.frame = CGRectMake(WIDTH/12, 0, 40, 40);
    
    UIButton *forward = [UIButton buttonWithType:UIButtonTypeSystem];
    [forward addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    forward.frame = CGRectMake(WIDTH*5/12, 0, 40, 40);
    forward.tag = 2;
    [forward setBackgroundImage:[self getBundleImage:forward.tag] forState:UIControlStateNormal];
    
    
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeSystem];
    [refresh addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    refresh.frame = CGRectMake(WIDTH*3/4, 0, 40, 40);
    refresh.tag = 3;
    [refresh setBackgroundImage:[self getBundleImage:refresh.tag] forState:UIControlStateNormal];
    
    [allView addSubview:back];
    [allView addSubview:forward];
    [allView addSubview:refresh];
    [self addSubview:allView];
}
- (void)click:(id)sender{
    UIButton *but = sender;
    if (but.tag==1) {
        [self goBack];
    }else if(but.tag==2){
        [self goForward];
    }else if(but.tag==3){
        [self reload];
    }
    
}

- (UIImage *)getBundleImage:(NSInteger)sender{
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"mcasimage" ofType:@"bundle"];
    NSArray *arr = [[NSArray alloc]initWithObjects:@"Remove.png",@"back.png",@"forward.png",@"refresh", nil];
    //拼接路径，获取图片路径
    NSString *imagePath = [bundlePath stringByAppendingPathComponent:[arr objectAtIndex:sender]];
    UIImage *locationImage = [UIImage imageWithContentsOfFile:imagePath];
    return locationImage;
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
