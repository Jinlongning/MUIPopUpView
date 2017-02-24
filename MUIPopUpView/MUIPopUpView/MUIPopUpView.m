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

@interface MUIPopUpView () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
/*!
 *  显示标题
 */
@property (strong, nonatomic) NSArray *titles;

@end

@implementation MUIPopUpView {

    CGFloat _arrowCenterOffset;
    ArrowDirection _arrowDirection;

    CAShapeLayer *_backgroundLayer;
}

#pragma mark -
#pragma mark - public

- (void)dealloc {
    
    NSLog(@"MUIPopUpView dealloc");
}

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles {
    
    if (self = [super initWithFrame:frame]) {
        
        self.alpha = 0.0;
        self.titles = titles ? : @[];
        self.userInteractionEnabled = YES;
        
        _backgroundLayer = [CAShapeLayer layer];
        _backgroundLayer.lineWidth = MUI_BORDER_WIDTH;
        _backgroundLayer.fillColor = MUIPopUpBackgroundColor.CGColor;
        _backgroundLayer.strokeColor = MUIPopUpBorderColor.CGColor;

        [self.layer addSublayer:_backgroundLayer];
    }
    
    [self setupTableViewWithFrame:frame];
    
    return self;
}

- (void)setArrowDirection:(ArrowDirection)arrowDirection {
    
    if (arrowDirection != _arrowDirection) {
        
        if (ArrowDirectionDown == _arrowDirection) {
            CGRect tableFrame = self.tableView.frame;
            tableFrame.origin.y -= MUI_ARROW_HEIGHT;
            self.tableView.frame = tableFrame;
        } else {
            CGRect tableFrame = self.tableView.frame;
            tableFrame.origin.y += MUI_ARROW_HEIGHT;
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
    
    [_backgroundLayer removeAnimationForKey:FillColorAnimation];
   
    _backgroundLayer.fillColor = color.CGColor;
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
        NSValue *fromValue2 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)];
        NSValue *fromValue = [self.layer animationForKey:@"transform"] ? fromValue1 : fromValue2;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = fromValue;
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        scaleAnimation.duration = 0.4;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        [scaleAnimation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.8 :2.5 :0.35 :0.5]];
        [self.layer addAnimation:scaleAnimation forKey:@"transform"];
        
        CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimation.fromValue = [self.layer.presentationLayer valueForKey:@"opacity"];
        fadeInAnimation.duration = 0.1;
        fadeInAnimation.toValue = @1.0;
        self.layer.opacity = 1.0;
        [self.layer addAnimation:fadeInAnimation forKey:@"opacity"];
    }
    
    [CATransaction commit];
}

- (void)hide {
    
    [CATransaction begin];
    
    {
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = [self.layer.presentationLayer valueForKey:@"transform"];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)];
        scaleAnimation.duration = 0.6;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        [scaleAnimation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.1 :-2 :0.3 :3]];
        [self.layer addAnimation:scaleAnimation forKey:@"transform"];
        
        CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOutAnimation.fromValue = [self.layer.presentationLayer valueForKey:@"opacity"];
        fadeOutAnimation.toValue = @0.0;
        fadeOutAnimation.duration = 0.8;
        self.layer.opacity = 0.0;
        [self.layer addAnimation:fadeOutAnimation forKey:@"opacity"];
    }
    
    [CATransaction commit];
}

#pragma mark -
#pragma mark - private

- (void)setupTableViewWithFrame:(CGRect)frame {
    
    CGRect tableFrame = CGRectMake(0,MUI_ARROW_HEIGHT,CGRectGetWidth(frame),CGRectGetHeight(frame)-MUI_ARROW_HEIGHT);
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
    roundedRect.size.height -= MUI_ARROW_HEIGHT;
    
    if (ArrowDirectionUp == _arrowDirection) {
        roundedRect.origin.y += MUI_ARROW_HEIGHT;
    }
    
    // Create rounded path
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:MUI_CORNER_RADIUS];
    
    // Create arrow path
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    CGFloat arrowX = CGRectGetMidX(self.bounds) + _arrowCenterOffset;
    
    if (ArrowDirectionDown == _arrowDirection) {
        [arrowPath moveToPoint:CGPointMake((arrowX - MUI_ARROW_HALFWIDTH), CGRectGetMaxY(roundedRect))];
        [arrowPath addLineToPoint:CGPointMake(arrowX, CGRectGetMaxY(self.bounds))];
        [arrowPath addLineToPoint:CGPointMake((arrowX + MUI_ARROW_HALFWIDTH), CGRectGetMaxY(roundedRect))];
//        [arrowPath closePath];

    } else {
        [arrowPath moveToPoint:CGPointMake((arrowX - MUI_ARROW_HALFWIDTH), CGRectGetMinX(roundedRect)+MUI_ARROW_HEIGHT)];
        [arrowPath addLineToPoint:CGPointMake(arrowX, CGRectGetMinX(self.bounds))];
        [arrowPath addLineToPoint:CGPointMake((arrowX + MUI_ARROW_HALFWIDTH), CGRectGetMinX(roundedRect)+MUI_ARROW_HEIGHT)];
//        [arrowPath closePath];
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
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        CGRect lineFrame = CGRectMake(0, MUI_POPUPCELL_HEIGHT-MUI_BORDER_WIDTH, CGRectGetWidth(self.bounds), MUI_BORDER_WIDTH);
        UIView *line = [[UIView alloc] initWithFrame:lineFrame];
        [line setBackgroundColor:MUIPopUpBorderColor];
        [cell addSubview:line];
    }
    
    if (indexPath.row < self.titles.count) {
       
        cell.textLabel.text = [self.titles objectAtIndex:indexPath.row];
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
