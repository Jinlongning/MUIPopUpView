//
//  MUIPopUpView.m
//  MUIPopUpView
//
//  Created by njl on 05/01/2017.
//  Copyright (c) 2017 njl. All rights reserved.
//

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// This UIView subclass is used internally by MUIPopUpView
// The public API is declared in MUIPopUpView.h
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#import "MUIPopUpView.h"

/*!
 *  边界线宽度
 */
static CGFloat const MUI_BORDER_WIDTH = 1.0;
/*!
 *  圆角半径
 */
static CGFloat const MUI_CORNER_RADIUS = 4.0;
/*!
 *  箭头半宽度
 */
static CGFloat const MUI_ARROW_HALFWIDTH = 6.0;
/*!
 *  箭头高度
 */
static CGFloat const MUI_ARROW_HEIGHT = 8.0;
/*!
 *  cell高度
 */
static CGFloat const MUI_POPUPCELL_HEIGHT = 34.0;
/*!
 *  动画
 */
static NSString * const FillColorAnimation = @"fillColor";

#define MUIPopUpBorderColor [UIColor colorWithRed:214/255.0 green:215/255.0 blue:215/255.0 alpha:1.0]
#define MUIPopUpBackgroundColor [UIColor whiteColor]


@interface MUIPopUpWindow : UIWindow

@property (strong, nonatomic) UIWindow *trick;
@property (strong, nonatomic) NSMutableArray *schedulingAlerts;

@end

@implementation MUIPopUpWindow

+ (instancetype)alertWindow {
    
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:self]) return (MUIPopUpWindow *)window;
    }
    
    MUIPopUpWindow *window = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelAlert;
    window.schedulingAlerts = [NSMutableArray array];
    return window;
}

- (void)oneFinger:(UITapGestureRecognizer *)gestureRecognizer {
    
    MUIPopUpView *alertView = [_schedulingAlerts lastObject];
    
    [alertView hide];
}

- (void)showAlertView:(UIView *)alertView {
    
    if (!alertView) return;
    [_schedulingAlerts addObject:alertView];
    [self showAlertViewIfPossible];
    [self advanceTrick];
}

- (void)dismissAlertView:(UIView *)alertView {
    
    if (!alertView) return;
    [_schedulingAlerts removeObject:alertView];
    [self showAlertViewIfPossible];
    [self advanceTrick];
    [self dismissAlertViewIfNeeded:alertView];
}

- (void)advanceTrick {
    
    self.trick = _schedulingAlerts.count > 0 ? self : nil;
}

- (void)showAlertViewIfPossible {
    
    UIView *alertView = [_schedulingAlerts lastObject];
    if (!alertView || alertView.window == self) return;
    
    self.hidden = NO;
    self.rootViewController = [[UIViewController alloc] init];
    UIView *container = self.rootViewController.view;
    
    [self addSubview:alertView];
    //[container addSubview:alertView];alertView加到containerView会造成cell的点击事件与container的点击事件冲突父事件拦截子事件的情况
    [container addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFinger:)]];
    
    alertView.translatesAutoresizingMaskIntoConstraints = NO;
    alertView.transform = CGAffineTransformMakeScale(0.3, 0.3);
    [UIView animateWithDuration:0.3f animations:^{
        alertView.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismissAlertViewIfNeeded:(UIView *)alertView {
    
    if (!alertView || alertView.window != self || _schedulingAlerts.count > 0) return;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.rootViewController.view.alpha = 0.f;
    } completion:^(BOOL finished) {
        self.rootViewController.view.alpha = 1.f;
        self.hidden = _schedulingAlerts.count == 0;
        [alertView removeFromSuperview];
    }];
}

@end

@interface MUIPopUpView () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
/*!
 *  显示标题
 */
@property (strong, nonatomic) NSArray *images;
/*!
 *  显示标题
 */
@property (strong, nonatomic) NSArray *titles;

@end

@implementation MUIPopUpView {
    
    CGFloat _arrowCenterOffset;
    CGFloat _arrowHeight;
    
    UIColor *_textColor;
    UIColor *_backgroundColor;
    
    ArrowDirection _arrowDirection;
    
    CAShapeLayer *_backgroundLayer;
}

#pragma mark -
#pragma mark - public

- (void)dealloc {
    
    NSLog(@"MUIPopUpView dealloc");
}

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles {
    
    return [self initWithFrame:frame titles:titles images:@[]];
}

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles images:(NSArray *)images {
    
    if (self = [super initWithFrame:frame]) {
        
        self.alpha = 0.0;
        self.images = images ? : @[];
        self.titles = titles ? : @[];
        self.userInteractionEnabled = YES;
        
        _arrowHeight = MUI_ARROW_HEIGHT;
        
        _textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        _backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        
        _backgroundLayer = [CAShapeLayer layer];
        _backgroundLayer.lineWidth = MUI_BORDER_WIDTH;
        _backgroundLayer.fillColor = MUIPopUpBackgroundColor.CGColor;
        _backgroundLayer.strokeColor = MUIPopUpBorderColor.CGColor;
        
        [self.layer addSublayer:_backgroundLayer];
        
        [self setupTableViewWithFrame:frame];
    }
    
    return self;
}

- (void)setArrowDirection:(ArrowDirection)arrowDirection {
    
    if (arrowDirection != _arrowDirection) {
        
        if (ArrowDirectionDown == _arrowDirection) {
            CGRect tableFrame = self.tableView.frame;
            tableFrame.origin.y -= _arrowHeight;
            self.tableView.frame = tableFrame;
        } else {
            CGRect tableFrame = self.tableView.frame;
            tableFrame.origin.y += _arrowHeight;
            self.tableView.frame = tableFrame;
        }
        
        _arrowDirection = arrowDirection > 0 ? ArrowDirectionDown : ArrowDirectionUp;
    }
}

- (void)setBorderColor:(UIColor *)color {
    
    [_backgroundLayer removeAnimationForKey:FillColorAnimation];
    
    _backgroundLayer.strokeColor = color.CGColor;
}

- (void)setBackgroundColor:(UIColor *)color {
    
    if ([color isKindOfClass:[UIColor class]]) {
        
        _backgroundColor = color;
        
        [_backgroundLayer removeAnimationForKey:FillColorAnimation];
        
        _backgroundLayer.fillColor = _backgroundColor.CGColor;
    }
}

- (void)setTextColor:(UIColor *)color {
    
    if ([color isKindOfClass:[UIColor class]]) {
        
        _textColor = color;
    }
}

- (void)setArrowHeight:(CGFloat)heitht {
    
    // only redraw if the offset has changed
    if (_arrowHeight != heitht) {
        
        _arrowHeight = heitht;
        
        CGRect tableRect = self.tableView.frame;
        tableRect.origin.y = _arrowHeight;
        tableRect.size.height = CGRectGetHeight(self.frame) - _arrowHeight;
        self.tableView.frame = tableRect;
        
        CGRect popUpRect = self.frame;
        
        [self drawPath];
        
        self.frame = popUpRect;// reset frame after redraw
    }
}

- (void)setArrowCenterOffset:(CGFloat)offset {
    
    // only redraw if the offset has changed
    if (_arrowCenterOffset != offset) {
        
        _arrowCenterOffset = offset;
        
        CGRect popUpRect = self.frame;
        
        [self drawPath];
        
        // reset frame after redraw
        self.frame = popUpRect;
    }
}

- (void)show {
    
    [self drawPath];
    
    [CATransaction begin];
    
    {
        // start the transform animation from its current value if it's already running
        NSValue *fromValue1 = [self.layer.presentationLayer valueForKey:@"transform"];
        NSValue *fromValue2 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.3, 0.3, 0.5)];
        NSValue *fromValue = [self.layer animationForKey:@"transform"] ? fromValue1 : fromValue2;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = fromValue;
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        scaleAnimation.duration = 0.3;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        [self.layer addAnimation:scaleAnimation forKey:@"transform"];
        
        CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimation.fromValue = [self.layer.presentationLayer valueForKey:@"opacity"];
        fadeInAnimation.duration = 0.2;
        fadeInAnimation.toValue = @1.0;
        self.layer.opacity = 1.0;
        
        [self.layer addAnimation:fadeInAnimation forKey:@"opacity"];
    }
    
    [CATransaction commit];
    
    [[MUIPopUpWindow alertWindow] showAlertView:self];
}

- (void)hide {
    
    [CATransaction begin];
    
    {
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = [self.layer.presentationLayer valueForKey:@"transform"];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.3, 0.3, 0.5)];
        scaleAnimation.duration = 0.3;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        [self.layer addAnimation:scaleAnimation forKey:@"transform"];
        
        CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOutAnimation.fromValue = [self.layer.presentationLayer valueForKey:@"opacity"];
        fadeOutAnimation.toValue = @0.0;
        fadeOutAnimation.duration = 0.25;
        self.layer.opacity = 0.0;
        
        [self.layer addAnimation:fadeOutAnimation forKey:@"opacity"];
    }
    
    [CATransaction commit];
    
    [[MUIPopUpWindow alertWindow] dismissAlertView:self];
}

#pragma mark -
#pragma mark - private

- (void)setupTableViewWithFrame:(CGRect)frame {
    
    CGRect tableFrame = CGRectMake(0,_arrowHeight,CGRectGetWidth(frame),CGRectGetHeight(frame)-_arrowHeight);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.clipsToBounds = YES;
    self.tableView.layer.cornerRadius = MUI_CORNER_RADIUS;
    
    [self addSubview:self.tableView];
}

- (void)drawPath {
    
    // Create rounded rect
    CGRect roundedRect = self.bounds;
    roundedRect.size.height -= _arrowHeight;
    
    if (ArrowDirectionUp == _arrowDirection) {
        roundedRect.origin.y += _arrowHeight;
    }
    
    // Create rounded path
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:MUI_CORNER_RADIUS];
    
    // Create arrow path
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    CGFloat arrowX = CGRectGetMidX(self.bounds) + _arrowCenterOffset;
    
    if (_arrowHeight > 0) {
        
        if (ArrowDirectionDown == _arrowDirection) {
            [arrowPath moveToPoint:CGPointMake((arrowX - MUI_ARROW_HALFWIDTH), CGRectGetMaxY(roundedRect))];
            [arrowPath addLineToPoint:CGPointMake(arrowX, CGRectGetMaxY(self.bounds))];
            [arrowPath addLineToPoint:CGPointMake((arrowX + MUI_ARROW_HALFWIDTH), CGRectGetMaxY(roundedRect))];
            //        [arrowPath closePath];
            
        } else {
            [arrowPath moveToPoint:CGPointMake((arrowX - MUI_ARROW_HALFWIDTH), CGRectGetMinX(roundedRect)+_arrowHeight)];
            [arrowPath addLineToPoint:CGPointMake(arrowX, CGRectGetMinX(self.bounds))];
            [arrowPath addLineToPoint:CGPointMake((arrowX + MUI_ARROW_HALFWIDTH), CGRectGetMinX(roundedRect)+_arrowHeight)];
            //        [arrowPath closePath];
        }
    }
    
    // combine arrow path and rounded rect
    [roundedRectPath appendPath:arrowPath];
    
    _backgroundLayer.path = roundedRectPath.CGPath;
}

#pragma mark -
#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUIPopUpCell"];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MUIPopUpCell"];
        cell.textLabel.textAlignment = _images.count ? NSTextAlignmentLeft : NSTextAlignmentCenter;
        cell.textLabel.textColor = _textColor;
        cell.backgroundColor = _backgroundColor;
        CGRect lineFrame = CGRectMake(0, MUI_POPUPCELL_HEIGHT-MUI_BORDER_WIDTH, CGRectGetWidth(self.bounds), MUI_BORDER_WIDTH);
        UIView *line = [[UIView alloc] initWithFrame:lineFrame];
        [line setBackgroundColor:MUIPopUpBorderColor];
        [cell addSubview:line];
    }
    
    if (indexPath.row < self.titles.count) {
        
        cell.textLabel.text = [self.titles objectAtIndex:indexPath.row];
        
        if (indexPath.row < self.images.count) {
            cell.imageView.image = [self.images objectAtIndex:indexPath.row];
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return MUI_POPUPCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.titles.count) {
        
        if (self.didSelectRowAtIndexPath) {
            
            self.didSelectRowAtIndexPath(indexPath);
        }
    }
}

@end
