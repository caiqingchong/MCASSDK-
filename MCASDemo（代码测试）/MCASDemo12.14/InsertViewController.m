//
//  InsertViewController.m
//  MCASDemo12.14
//
//  Created by Apple on 15/12/15.
//  Copyright © 2015年 mcas. All rights reserved.
//

#import "InsertViewController.h"
#import "MCASInterstitial.h"
@interface InsertViewController (){

    MCASInterstitial *insert;
}

@end

@implementation InsertViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
    insert = [[MCASInterstitial alloc]initWithAppID:@"09c4aaeb-2feb-45f0-b587-5d9e928157b8" slotID:@"b0507821-caaa-436c-9561-65a6325f1294"];
    [insert loadInterstitial];
    
    
    UIButton *but =[UIButton buttonWithType:UIButtonTypeSystem];
    [but setTitle:@"获取广告" forState:UIControlStateNormal];
    but.frame = CGRectMake(0, 400, 50, 20);
    but.backgroundColor = [UIColor redColor];
    [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(backUrl) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
}

- (void)backUrl{
    [insert showInterstitial:self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
