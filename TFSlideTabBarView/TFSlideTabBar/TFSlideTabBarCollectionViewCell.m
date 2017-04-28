//
//  TFSlideTabBarCollectionViewCell.m
//  TFSlideTabBarDemo
//
//  Created by 江霆锋 on 2017/4/27.
//  Copyright © 2017年 江霆锋. All rights reserved.
//

#import "TFSlideTabBarCollectionViewCell.h"

@implementation TFSlideTabBarCollectionViewCell

- (void)setSubViewController:(UIViewController *)subViewController{
    _subViewController = subViewController;
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.contentView addSubview:subViewController.view];
    subViewController.view.frame = self.bounds;
}

@end
