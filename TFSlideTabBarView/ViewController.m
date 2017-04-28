//
//  ViewController.m
//  TFSlideTabBarDemo
//
//  Created by 江霆锋 on 2017/4/27.
//  Copyright © 2017年 江霆锋. All rights reserved.
//

#import "ViewController.h"
#import "TFSlideTabBar.h"
#import "TestViewController.h"
@interface ViewController ()
@property (nonatomic,strong) TFSlideTabBar * slideTabBar;
@end

@implementation ViewController

-(TFSlideTabBar *)slideTabBar{
    
    if (!_slideTabBar) {
        _slideTabBar = ({
            TFSlideTabBar * tabbar = [[TFSlideTabBar alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
            
            TestViewController * vc0 = [[TestViewController alloc]init];
            vc0.title = @"推荐";
            [tabbar addSubItemWithViewController:vc0];
            
            TestViewController * vc1 = [[TestViewController alloc]init];
            vc1.title = @"国产";
            [tabbar addSubItemWithViewController:vc1];
            
            TestViewController * vc2 = [[TestViewController alloc]init];
            vc2.title = @"日韩";
            [tabbar addSubItemWithViewController:vc2];
            
            TestViewController * vc3 = [[TestViewController alloc]init];
            vc3.title = @"欧美";
            [tabbar addSubItemWithViewController:vc3];
            
            TestViewController * vc4 = [[TestViewController alloc]init];
            vc4.title = @"动漫";
            [tabbar addSubItemWithViewController:vc4];
            
            TestViewController * vc5 = [[TestViewController alloc]init];
            vc5.title = @"迷情校园";
            [tabbar addSubItemWithViewController:vc5];
            
            TestViewController * vc6 = [[TestViewController alloc]init];
            vc6.title = @"武侠经典";
            [tabbar addSubItemWithViewController:vc6];
            
            TestViewController * vc7 = [[TestViewController alloc]init];
            vc7.title = @"制服丝袜";
            [tabbar addSubItemWithViewController:vc7];
            
            TestViewController * vc8 = [[TestViewController alloc]init];
            vc8.title = @"清纯唯美";
            [tabbar addSubItemWithViewController:vc8];
            
            tabbar;
        });
    }
    return _slideTabBar;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.slideTabBar];
    self.automaticallyAdjustsScrollViewInsets = NO;
}


@end
