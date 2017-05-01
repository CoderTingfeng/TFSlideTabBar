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

//RGB颜色
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

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


@property (nonatomic, weak) UIView *markView;
@property (nonatomic, assign) BOOL isRecoverDirection; // 是否需要修正挪动方向
@property (nonatomic, assign) BOOL isDragToLeft;    // 是否往左挪
@property (nonatomic, assign) CGFloat lastOffsetX;  // 上一次的水平偏移量
@property (nonatomic, assign) CGFloat currBtnX;
@property (nonatomic, assign) CGFloat currBtnW;
@property (nonatomic, assign) CGFloat currBtnCenterX;
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
    
    
    UIView *markView = [[UIView alloc] init];
    markView.backgroundColor = [UIColor greenColor];
    markView.layer.masksToBounds = YES;
    markView.layer.cornerRadius = 1;
    [slideTabBar addSubview:markView];
    self.markView = markView;
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
        
        UIButton * btn = self.btnArray[i];
        btn.frame = CGRectMake(btnX, 0, btn.frame.size.width, btnH);
        btnX += btn.frame.size.width + tabBarItemMargin;
        
        
        if (i == 0 && self.markView.frame.size.width == 0) {
            CGRect frame = self.markView.frame;
            frame.origin.x = btn.frame.origin.x;
            frame.size.width = btn.frame.size.width;
            frame.origin.y = tabBarHeight - 2;
            frame.size.height = 2;
            self.markView.frame = frame;
        }
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / ScreenW;
    
    UIButton *btn = self.btnArray[index];
    self.currBtnW = btn.frame.size.width;
    self.currBtnX = btn.frame.origin.x;
    self.currBtnCenterX = btn.frame.origin.x + btn.frame.size.width * 0.5;
    self.isRecoverDirection = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.isAnimation) return;
    
    CGFloat offsetX = scrollView.contentOffset.x;
    
    CGFloat scale = offsetX / ScreenW;
    
    if (scale < 0 || scale > self.btnArray.count - 1) return;
    
    
    UIButton *currBtn = self.btnArray[(NSInteger)scale];
    CGFloat currCenterX = currBtn.frame.origin.x + currBtn.frame.size.width * 0.5;
    
    if ((self.isDragToLeft && currCenterX < self.currBtnCenterX) ||
        (!self.isDragToLeft && currCenterX >= self.currBtnCenterX)) {
        self.isRecoverDirection = YES;
    }
    
    if (self.isRecoverDirection) {
        self.isRecoverDirection = NO;
        self.isDragToLeft = offsetX > self.lastOffsetX;
    }
    
    self.lastOffsetX = offsetX; // 保存水平偏移量
    
    CGRect frame = self.markView.frame;
    CGFloat h = frame.size.height;
    CGFloat y = frame.origin.y;
    CGFloat x;
    CGFloat w;
    
    NSInteger targetIndex;
    
    if (self.isDragToLeft) {
        targetIndex = (NSInteger)(scale + 1.0);
    } else {
        targetIndex = (NSInteger)(scale);
    }
    
    if (targetIndex > self.btnArray.count - 1) {
        targetIndex = self.btnArray.count - 1;
    } else if (targetIndex < 0) {
        targetIndex = 0;
    }
    
    UIButton *btn = self.btnArray[targetIndex];
    CGFloat targetW = btn.frame.size.width;
    CGFloat targetX = btn.frame.origin.x;
    CGFloat targetMaxX = targetX + targetW;
    
    if (self.isDragToLeft) {
        
        // 获取目标的左边下标
        NSInteger lastIndex = targetIndex - 1;
        if (lastIndex < 0) lastIndex = 0;
        
        UIButton *lastBtn = self.btnArray[lastIndex];
        
        // 前一个文字宽度
        CGFloat lastW = lastBtn.frame.size.width;
        
        // 前一个文字X
        CGFloat lastX = lastBtn.frame.origin.x;
        // 前一个文字最大X
        CGFloat lastMaxX = lastX + lastW;
        
        // 最终需要增加的W
        CGFloat increaseW = targetMaxX - lastMaxX;
        
        w = (lastMaxX - self.currBtnX) + increaseW * (scale - lastIndex);
        x = self.currBtnX;
        
    } else {
        
        // 获取目标下标的右边下标
        NSInteger nextIndex = targetIndex + 1;
        if (nextIndex > self.btnArray.count - 1) nextIndex = self.btnArray.count - 1;
        
        UIButton *nextBtn = self.btnArray[nextIndex];
        
        CGFloat nextW = nextBtn.frame.size.width;
        CGFloat nextX = nextBtn.frame.origin.x;
        
        // 最终需要增加的W
        CGFloat increaseW = (nextX - targetX) * (1 - (scale - targetIndex)); // 这里的scale需要取反，因为是反方向
        
        w = nextW + increaseW;
        x = self.currBtnX - increaseW;
        
    }
    
    self.markView.frame = CGRectMake(x, y, w, h);
    
    NSLog(@"currCenterX -------- %lf", currCenterX);
    NSLog(@"currTitleCenterX --- %lf", self.currBtnCenterX);
    NSLog(@"isDragToLeft ------- %@", self.isDragToLeft ? @"往左挪":@"往右挪");
    
    
    
    
    
    NSInteger leftIndex = scale;
    NSInteger rightIndex = leftIndex + 1;
    
    
    
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
     * 0 - 255 = -255
     * 0 - 0 = 0
     */
    
    CGFloat r = 0 - leftScale * 0;
    CGFloat g = 0 - leftScale * (-255);
    CGFloat b = 0 - leftScale * 0;
    
    UIColor *leftColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
    
    //    NSLog(@"leftG --- %lf", g);
    
    [leftBtn setTitleColor:leftColor forState:UIControlStateNormal];
    
    r = 0 - rightScale * 0;
    g = 0 - rightScale * (-255);
    b = 0 - rightScale * 0;
    
    UIColor *rightColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
    
    //    NSLog(@"rightG --- %lf", g);
    
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
    
    
    NSInteger index = scrollView.contentOffset.x / ScreenW;
    
    CGRect frame = self.markView.frame;
    
    CGFloat h = frame.size.height;
    CGFloat y = frame.origin.y;
    
    UIButton *currBtn = self.btnArray[index];
    CGFloat w = currBtn.frame.size.width;
    CGFloat x = currBtn.frame.origin.x;
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        self.markView.frame = CGRectMake(x, y, w, h);
    } completion:nil];
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
        [self.slideTabBar setContentOffset:CGPointMake(offsetX, 0)];
        
        
        self.markView.frame = CGRectMake(btn.frame.origin.x, self.markView.frame.origin.y, btn.frame.size.width, self.markView.frame.size.height);
        
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
    //    [btn setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
}

@end
