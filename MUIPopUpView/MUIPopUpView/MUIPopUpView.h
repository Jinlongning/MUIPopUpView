//
//  MUIPopUpView.h
//  MUIPopUpView
//
//  Created by njl on 05/01/2017.
//  Copyright (c) 2017 njl. All rights reserved.
//

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// This UIView subclass is used internally by MUIPopUpView
// The public API is declared in MUIPopUpView.h
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#import <UIKit/UIKit.h>

/*!
 *  箭头方向
 */
typedef NS_ENUM(NSInteger, ArrowDirection) {
   
    ArrowDirectionUp = 0,
    ArrowDirectionDown
};

/*!
 *  CELL点击回调
 */
typedef void(^DidSelectRowAtIndexPath)(NSIndexPath *indexPath);

@interface MUIPopUpView : UIView

/**
 *    @param frame frame
 *
 *    @param titles 显示标题数组
 */
- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles;

/**
 *    @param frame frame
 *
 *    @param titles 显示标题数组
 *    @param images 显示图标数组
 */
- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles images:(NSArray *)images;
/**
 *    设置边界色
 */
- (void)setBorderColor:(UIColor *)color;

/**
 *    设置背景色
 */
- (void)setBackgroundColor:(UIColor *)color;

/**
 *    设置箭头偏移量，默认居中
 */
- (void)setArrowCenterOffset:(CGFloat)offset;

/**
 *    设置箭头方向，默认向上
 */
- (void)setArrowDirection:(ArrowDirection)arrowDirection;

/*!
 *  CELL点击回调
 */
@property (copy, nonatomic) DidSelectRowAtIndexPath didSelectRowAtIndexPath;

/*!
 *  显示
 */
- (void)show;

/*!
 *  隐藏
 */
- (void)hide;

@end
