//
//  PS_TabBarViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_TabBarViewController.h"
#import "PS_CustomTabBarView.h"
#import "PS_BloomView.h"

#define kEditViewHeight 300

@interface PS_TabBarViewController ()<tabBarDelegate,BloomDelegate>

@property (nonatomic, strong) PS_CustomTabBarView *customView;
@property (nonatomic, strong) PS_BloomView *bloomView;
@property (nonatomic, strong) UIView *backView;

@end

@implementation PS_TabBarViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.tabBar.barTintColor = [UIColor clearColor];
        
        _customView = [[PS_CustomTabBarView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
        _customView.delegate = self;
        [self.tabBar addSubview:_customView];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark -- tabBarDelegate -- 
- (void)tabBarButtonClickWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            [self showRootViewController:0];
            self.selectedIndex = 0;
            break;
        case 1:
            [self showRootViewController:1];
            self.selectedIndex = 1;
            break;
        case 2:
            //第三个按钮不会切换controller,只是展示一个view菜单
            [self showEditView];
            break;
        case 3:
            [self showRootViewController:2];
            self.selectedIndex = 2;
            break;
        case 4:
            [self showRootViewController:3];
            self.selectedIndex = 3;
            break;
        default:
            break;
    }
}

//重复点击tabbar某个按钮则回到首页,否则不变
- (void)showRootViewController:(NSInteger)index
{
    UINavigationController *na = self.viewControllers[index];
    if (self.selectedViewController == na) {
        [na popToRootViewControllerAnimated:YES];
    }
}

- (void)showEditView
{
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight)];
    _backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    [self.view.window addSubview:_backView];
    
    _bloomView = [[PS_BloomView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    _bloomView.center = CGPointMake(kWindowWidth/2, kWindowHeight -26);
    _bloomView.backgroundColor = [UIColor colorWithRed:66/255.0 green:207/255.0 blue:155/255.0 alpha:0.9];
    _bloomView.layer.cornerRadius = 32;
    _bloomView.delegate = self;
    [self.view.window addSubview:_bloomView];
    
    _backView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        _customView.button.hidden = YES;
        _backView.alpha = 1;
        CGRect rect  = self.tabBar.frame;
        self.tabBar.frame = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width, rect.size.height);
    } completion:nil];
    
    [_bloomView bloomAnimation];
}

//- (void)handleTap:(UITapGestureRecognizer *)tap
//{
//    [UIView animateWithDuration:0.5 animations:^{
//        _editView.frame = CGRectMake(0, kWindowHeight, kWindowWidth, kEditViewHeight);
//    } completion:^(BOOL finished) {
//        [_editView.superview removeFromSuperview];
//    }];
//}

#pragma mark --BloomDelegate
-(void)shopBtnOnClick
{
    NSLog(@"shop");
}

-(void)imageBtnOnClick
{
    NSLog(@"image");
}

-(void)videoBtnOnClick
{
    NSLog(@"video");
}

//只有回收动画会回调
-(void)centerBtnOnClick
{
    [UIView animateWithDuration:0.3 animations:^{
        _customView.button.hidden = NO;
        CGRect rect  = self.tabBar.frame;
        self.tabBar.frame = CGRectMake(rect.origin.x, rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
        _backView.alpha = 0;
    } completion:^(BOOL finished) {
        [_backView removeFromSuperview];
        [_bloomView removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
