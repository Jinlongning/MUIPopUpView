//
//  ViewController.m
//  MUIPopUpView
//
//  Created by King on 2017/2/24.
//  Copyright © 2017年 King. All rights reserved.
//

#import "MUIPopUpView.h"
#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) MUIPopUpView *popUpView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(200, 100, 100, 30)];
    [button1 setTitle:@"show" forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor greenColor];
    [button1 addTarget:self action:@selector(showPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
//    NSArray *title = @[@"11",@"22",@"33",@"44",@"55",@"66",@"77",@"88",@"99"];
//    MUIPopUpView *popUpView = [[MUIPopUpView alloc] initWithFrame:CGRectMake(150, 250, 160, 158) titles:title];
//
//    __weak typeof(popUpView) weakPopUpView = popUpView;
//    popUpView.didSelectRowAtIndexPath = ^(NSIndexPath *indexPath) {
//        typeof(&*weakPopUpView) strongPopUpView = weakPopUpView;
//        NSLog(@"%@",indexPath);
//        [strongPopUpView hide];
//        [strongPopUpView removeFromSuperview];
//    };
//    [self.view addSubview:popUpView];
}

- (MUIPopUpView *)popUpView {
    
    if (!_popUpView) {
        NSArray *title = @[@"11",@"22",@"33",@"44",@"55",@"66",@"77",@"88",@"99"];
        MUIPopUpView *popUpView = [[MUIPopUpView alloc] initWithFrame:CGRectMake(150, 250, 160, 158) titles:title];
        [self.view addSubview:popUpView];
        _popUpView = popUpView;
    }
    
    return _popUpView;
}

- (void)showPage:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    self.popUpView.didSelectRowAtIndexPath = ^(NSIndexPath *indexPath) {
        typeof(&*weakSelf) strongSelf = weakSelf;
        NSLog(@"%@",indexPath);
        [strongSelf.popUpView hide];
        [strongSelf.popUpView removeFromSuperview];
    };
    
    [self.popUpView show];
}

@end
