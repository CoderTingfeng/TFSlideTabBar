//
//  TFSlideTabBarCollectionViewCell.h
//  TFSlideTabBarDemo
//
//  Created by 江霆锋 on 2017/4/27.
//  Copyright © 2017年 江霆锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFSlideTabBarCollectionViewCell : UICollectionViewCell
/**
 一个cell带一个子控制器
 */
@property (nonatomic,strong) UIViewController *subViewController;

@end
