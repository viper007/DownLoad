//
//  MYCircleBar.m
//  Manyi
//
//  Created by 满艺网 on 2017/8/4.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import "MYCircleBar.h"

@interface MYCircleBar ()

@property (nonatomic ,strong) NSMutableArray *buttonsArray;
@property (nonatomic ,strong) UIButton *preButton;
@property (nonatomic) NSArray *titlesArray;

@property (nonatomic ,strong) UIView *topView;
@property (nonatomic ,strong) UIView *middleView;

@end

@implementation MYCircleBar{
    UIColor *_normalColor;
    UIColor *_disableColor;
    NSArray *_titlesArray;
}

- (NSMutableArray *)buttonsArray {
    if (!_buttonsArray) {
        _buttonsArray = [NSMutableArray array];
    }
    return _buttonsArray;
}
+ (instancetype)cireleBarframe:(CGRect)frame NarmalColor:(UIColor *)normalColor disableColor:(UIColor *)disableColor titles:(NSArray *)titles {
    //
    return [[self alloc] initWithFrame:frame CireleBarNarmalColor:normalColor disableColor:disableColor titles:titles];
}

- (instancetype)initWithFrame:(CGRect)frame CireleBarNarmalColor:(UIColor *)normalColor disableColor:(UIColor *)disableColor titles:(NSArray *)titles {
    if (self = [super initWithFrame:frame]) {
        
        _normalColor = normalColor;
        _disableColor = disableColor;
        self.circleBarTitles = titles;
        
        self.backgroundColor = [UIColor clearColor];
        //
        [self.layer setCornerRadius:frame.size.height*0.5];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderColor:_normalColor.CGColor];
        [self.layer setBorderWidth:1];
        [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self setupButton:titles[idx] Tag:idx];
        }];
        //
        self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/titles.count, self.frame.size.height)];
        self.topView.clipsToBounds = YES;
        [self.topView.layer setCornerRadius:frame.size.height*0.5];
        [self.topView.layer setMasksToBounds:YES];
        [self addSubview:self.topView];
        //
        self.middleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.middleView.backgroundColor = _normalColor;
        //
        [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self setupButton:titles[idx] topTag:idx];
        }];
        [self.topView addSubview:self.middleView];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        [self.topView addGestureRecognizer:panGesture];
        //
    }
    return self;
}

- (void)panView:(UIPanGestureRecognizer *)pan {
    
    //
    CGPoint point        = [pan translationInView:self];
    CGPoint topCenter    = self.topView.center;
    CGPoint middleCenter = self.middleView.center;
    
    topCenter.x         += point.x;
    middleCenter.x      -= point.x;
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:
        {
            if (topCenter.x >= self.frame.size.width - self.topView.frame.size.width*0.5 || topCenter.x <= self.topView.frame.size.width*0.5) {
                topCenter.x -= point.x;
                middleCenter.x += point.x;
            }
            //判断对应的这个view的中心点是否越界
            _topView.center      = topCenter;
            _middleView.center   = middleCenter;
            [pan setTranslation:CGPointZero inView:self];
        }
            break;
        case UIGestureRecognizerStateEnded: {
             //计算当前对应的center
            _topView.center      = topCenter;
            _middleView.center   = middleCenter;
            [pan setTranslation:CGPointZero inView:self];
             //
             int index = 0;
             UIButton *indexButton = self.buttonsArray[index];
             CGFloat margin =  fabs(indexButton.center.x - topCenter.x);
             for (int i = 0; i < self.buttonsArray.count; i++) {
                UIButton *btn = self.buttonsArray[i];
                CGFloat calMargin = fabs(btn.center.x - topCenter.x);
                if (margin > calMargin) {
                    margin = calMargin;
                    index = i;
                    indexButton = btn;
                }
            }
            [self clickButton:indexButton];
        }break;
        default:
            break;
    }
}

- (void)setCircleBarTitles:(NSArray *)circleBarTitles {
    _circleBarTitles = circleBarTitles;
    
    //[self setupButtons];
}

- (void)setupButtons {
    self.buttonsArray = [NSMutableArray array];
    //
    [self.circleBarTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setupButton:title Tag:idx];
    }];
    self.preButton = [self.buttonsArray firstObject];
    
    //
    [self.circleBarTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setupButton:title topTag:idx];
    }];
    [self setNeedsLayout];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    //
    CGFloat width = self.frame.size.width / self.buttonsArray.count;
    __block CGFloat x = 0;
    CGFloat y = 0;
    CGFloat height = self.frame.size.height;
    [self.buttonsArray enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        x = idx * width;
        UIButton *btn = self.middleView.subviews[idx];
        btn.frame = button.frame = CGRectMake(x, y, width, height);
    }];
}

#pragma mark --Method
- (void)clickButton:(UIButton *)button {
    //1.更改上次按钮的状态
      self.preButton = button;
    //2.
    [self dynamicChangeCenter:button.center];
    //3.代理方法
    if ([self.delegate respondsToSelector:@selector(clickCircleBarAtIndex:)]) {
        [self.delegate clickCircleBarAtIndex:button.tag];
    }
}

/** @breif  动态改变白色背景view的frame  */
- (void)dynamicChangeCenter:(CGPoint)point {
     __block CGPoint topCenter = self.topView.center;
     __block CGPoint midCenter = self.middleView.center;
     CGFloat offset = point.x - topCenter.x;
     midCenter.x -= offset;//向左移动
     [UIView animateWithDuration:0.25 animations:^{
        self.topView.center = point;
        self.middleView.center = midCenter;
     }];
}
/** @breif  点击第三个需要登录的问题  */
- (void)setSelectedRecommend:(BOOL)selectedRecommend {
    _selectedRecommend = selectedRecommend;
    if (selectedRecommend) {
        [self clickButton:self.subviews[0]];
    }
}

#pragma mark - -initSubViews Method
/** @breif  设置最底部的按妞状态  */
- (void)setupButton:(NSString *)title Tag:(NSUInteger)tag {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateDisabled];
    [btn setTitleColor:_normalColor  forState:UIControlStateNormal];
    [btn setTitleColor:_disableColor  forState:UIControlStateDisabled];
    [btn.layer setCornerRadius:self.frame.size.height*0.5];
    [btn.layer setMasksToBounds:YES];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    //
    [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat width = self.frame.size.width / self.circleBarTitles.count;
    btn.frame = CGRectMake(tag * width, 0, width, self.frame.size.height);
    [self addSubview:btn];
    [self.buttonsArray addObject:btn];
}

/** @breif  设置最底部的按妞状态  */
- (void)setupButton:(NSString *)title topTag:(NSUInteger)tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.userInteractionEnabled = NO;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateDisabled];
    [btn setTitleColor:_disableColor forState:UIControlStateNormal];
    [btn setTitleColor:_normalColor  forState:UIControlStateDisabled];
    [btn.layer setCornerRadius:self.frame.size.height*0.5];
    [btn.layer setMasksToBounds:YES];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    //
    CGFloat width = self.frame.size.width / self.circleBarTitles.count;
    btn.frame = CGRectMake(tag * width, 0, width, self.frame.size.height);
    [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.middleView addSubview:btn];
}

@end
