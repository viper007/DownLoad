//
//  MYCircleBar.h
//  Manyi
//
//  Created by 满艺网 on 2017/8/4.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MYCircleBarDelegate <NSObject>
@optional
- (void)clickCircleBarAtIndex:(NSInteger)index;
- (void)clickCircleBarDefaultButton;
@end

@interface MYCircleBar : UIView

+ (instancetype)cireleBarframe:(CGRect)frame NarmalColor:(UIColor *)normalColor disableColor:(UIColor *)disableColor titles:(NSArray *)titles;

@property (nonatomic ,strong) NSArray *circleBarTitles;

@property (nonatomic ,weak) id<MYCircleBarDelegate> delegate;
/** @property YES选中第一个  */
@property (nonatomic ,assign) BOOL selectedRecommend;
@end
