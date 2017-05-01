//
//  TFSlideTabBar.m
//  TFSlideTabBarDemo
//
//  Created by 江霆锋 on 2017/4/27.
//  Copyright © 2017年 江霆锋. All rights reserved.
//

#import "TFSlideTabBar.h"
#import "TFSlideTabBarCollectionViewCell.h"
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
//标题之间的间距
static CGFloat const tabBarItemMargin = 15;
//顶部标签条的高度
static CGFloat const tabBarHeight = 40;

static NSString * const cellID = @"TFSlideTabBarCollectionViewCell";

@interface TFSlideTabBar()<UICollectionViewDataSource,UICollectionViewDelegate>
/**
 标签按钮数组
 */
@property (nonatomic,strong) NSMutableArray * btnArray;
/**
 子控制器数组
 */
@property (nonatomic,strong) NSMutableArray * subViewControllers;
/**
 顶部用UIScrollView 滚动标签条
 */
@property (nonatomic,weak) UIScrollView * slideTabBar;
/**
 底部用UICollectionView实现会比用UIScrollView性能好很多
 */
@property (nonatomic,weak) UICollectionView * contentView;
/**
 选择的下标
 */
@property (nonatomic,assign) NSInteger  selectedIndex;

@property (nonatomic,assign) NSInteger  preSelectedIndex;
/**
 滚动标签条的宽度
 */
@property (nonatomic,assign) CGFloat  tabBarWidth;

@property (nonatomic, assign) BOOL isAnimation;
@end
@implementation TFSlideTabBar

- (NSMutableArray *)btnArray{
    
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

- (NSMutableArray *)subViewControllers{
    
    if (!_subViewControllers) {
        _subViewControllers = [NSMutableArray array];
    }
    return _subViewControllers;
}


/**
 初始化
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectedIndex = 0;
        _preSelectedIndex = 0;
        _tabBarWidth = tabBarItemMargin;
        self.backgroundColor = [UIColor redColor];
        [self setUpSubview];
    }
    return self;
}


/**
 添加子控件
 */
- (void)setUpSubview{
    
    UIScrollView * slideTabBar = [[UIScrollView alloc]init];
    [self addSubview:slideTabBar];
    self.slideTabBar = slideTabBar;
    slideTabBar.showsHorizontalScrollIndicator = NO;
    slideTabBar.showsVerticalScrollIndicator = NO;
    slideTabBar.backgroundColor = [UIColor orangeColor];
    slideTabBar.bounces = YES;
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    //设置layout 属性
    layout.itemSize = (CGSize){self.bounds.size.width,(self.bounds.size.height - tabBarHeight)};
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    
    UICollectionView * contentView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    [self addSubview:contentView];
    
    self.contentView = contentView;
    contentView.showsHorizontalScrollIndicator = NO;
    contentView.pagingEnabled = YES;
    contentView.bounces = YES;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.dataSource = self;
    contentView.delegate = self;
    
    //注册cell
    [contentView registerClass:[TFSlideTabBarCollectionViewCell class] forCellWithReuseIdentifier:cellID];
}


/**
 布局子控件
 */
-(void)layoutSubviews{
    
    [super layoutSubviews];
    self.slideTabBar.frame = CGRectMake(0, 0, self.bounds.size.width, tabBarHeight);
    self.slideTabBar.contentSize = CGSizeMake(self.tabBarWidth, 0);
    
    self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.slideTabBar.frame), self.bounds.size.width, self.bounds.size.height - tabBarHeight);
    CGFloat btnH = tabBarHeight;
    CGFloat btnX = tabBarItemMargin;
    for (int i = 0 ; i < self.btnArray.count; i++) {
        
        UIButton * btn = self.slideTabBar.subviews[i];
        btn.frame = CGRectMake(btnX, 0, btn.frame.size.width, btnH);
        btnX += btn.frame.size.width + tabBarItemMargin;
    }
    
    
    //默认选第0个
    [self itemSelectedIndex:0];
    
}


/**
 CollectionViewDataSource方法
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.subViewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TFSlideTabBarCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    cell.subViewController = self.subViewControllers[indexPath.row] ;
    
    return cell;
    
}


/**
 UIScrollViewDelegate代理方法
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    
    if (self.isAnimation) return;
    
    CGFloat scale = scrollView.contentOffset.x / scrollView.frame.size.width;
    //向右滑 leftIndex = 当前index 向左滑 leftIndex已经减1  rightIndex = 当前index
    NSInteger leftIndex = scale;
    NSInteger rightIndex = leftIndex + 1;
    if (scale < 0 || scale > self.btnArray.count - 1) return;
    
    // 获得需要操作的左边label
    UIButton *leftBtn = self.btnArray[leftIndex];
    
    // 获得需要操作的右边label
    UIButton *rightBtn = (rightIndex == self.btnArray.count) ? nil : self.btnArray[rightIndex];
    
    // 右边比例
    CGFloat rightScale = scale - leftIndex;
    // 左边比例
    CGFloat leftScale = 1 - rightScale;
    
    //    NSLog(@"leftScale --- %lf", leftScale);
    //    NSLog(@"rightScale -- %lf", rightScale);
    
    // 设置label的比例
    /**
     * 0 - 0 = 0
     * 0 - （-255） = 255
     * 0 - 0 = 0
     */
    
    CGFloat r = 0 - leftScale * 0;
    CGFloat g = 0 - leftScale * (-255);
    CGFloat b = 0 - leftScale * 0;
    
    UIColor *leftColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
    
    
    
    [leftBtn setTitleColor:leftColor forState:UIControlStateNormal];
    
    r = 0 - rightScale * 0;
    g = 0 - rightScale * (-255);
    b = 0 - rightScale * 0;
    
    UIColor *rightColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
    
    
    
    [rightBtn setTitleColor:rightColor forState:UIControlStateNormal];
    
    UIFont *leftFont = [UIFont systemFontOfSize:15 + leftScale * 3];
    UIFont *rightFont = [UIFont systemFontOfSize:15 + rightScale * 3];
    
    leftBtn.titleLabel.font = leftFont;
    rightBtn.titleLabel.font = rightFont;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(self.selectedIndex != (scrollView.contentOffset.x + ScreenW * 0.5) / ScreenW){
        self.selectedIndex = (scrollView.contentOffset.x + ScreenW * 0.5) / ScreenW;
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        //设置按钮选中
        [self itemSelectedIndex:self.selectedIndex];
    }
}


/**
 根据选中下标设置标签按钮偏移量
 */
- (void)itemSelectedIndex:(NSInteger)index{
    
    UIButton * preSelectedBtn = self.btnArray[_preSelectedIndex];
    preSelectedBtn.selected = NO;
    [preSelectedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _selectedIndex = index;
    _preSelectedIndex = _selectedIndex;
    UIButton * selectedBtn = self.btnArray[index];
    selectedBtn.selected = YES;
    [selectedBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    
    self.isAnimation = YES;
    [UIView animateWithDuration:0.25 animations:^{
        preSelectedBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        selectedBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        
        UIButton * btn = self.btnArray[self.selectedIndex];
        // 计算偏移量
        CGFloat offsetX = btn.center.x - ScreenW * 0.5;
        if (offsetX < 0) offsetX = 0;
        // 获取最大滚动范围
        CGFloat maxOffsetX = self.slideTabBar.contentSize.width - ScreenW;
        if (offsetX > maxOffsetX) offsetX = maxOffsetX;
        
        // 如果标签过少 导致tabbar宽度没超过屏幕宽度
        if (self.tabBarWidth < self.bounds.size.width) {
            offsetX = 0;
        }
        [self.slideTabBar setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    } completion:^(BOOL finished) {
        self.isAnimation = NO;
    }];
}


/**
 根据选中下标设置子contentView偏移量
 */
- (void)itemSelected:(UIButton *)btn{
    
    NSInteger index = [self.btnArray indexOfObject:btn];
    [self itemSelectedIndex:index];
    self.selectedIndex = index;
    self.contentView.contentOffset = CGPointMake(index * self.bounds.size.width, 0);
}


/**
 外部接口 添加子控制器
 */
- (void)addSubItemWithViewController:(UIViewController *)viewController{
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.slideTabBar addSubview:btn];
    [self.btnArray addObject:btn];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self setupBtn:btn withTitle:viewController.title];
    [btn addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.subViewControllers addObject:viewController];
}


/**
 设置顶部标签按钮
 */
- (void)setupBtn:(UIButton *)btn withTitle:(NSString *)title{
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn sizeToFit];
    self.tabBarWidth += btn.frame.size.width + tabBarItemMargin;
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
}

@end
