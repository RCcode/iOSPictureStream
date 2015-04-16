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

@property (nonatomic,retain) UIView *editView;

@end

@implementation PS_TabBarViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    PS_CustomTabBarView *view = [[PS_CustomTabBarView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
    view.delegate = self;
    [self.tabBar addSubview:view];
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
    PS_BloomView *bloomView = [[PS_BloomView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    bloomView.center = CGPointMake(kWindowWidth/2, kWindowHeight -25);
    bloomView.backgroundColor = [UIColor redColor];
    bloomView.layer.cornerRadius = 32;
    bloomView.delegate = self;
    [self.view.window addSubview:bloomView];
    
    
//    [UIView animateWithDuration:0.2 animations:^{
//       bloomView.frame = CGRectMake(0, 0, 64, 64);
//        
//    } completion:^(BOOL finished) {
//        [bloomView bloomAnimation];
//    }];
    [bloomView bloomAnimation];
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
-(void)imageBtnOnClick
{
    NSLog(@"image");
}

-(void)videoBtnOnClick
{
    NSLog(@"video");
}

-(void)shopBtnOnClick
{
    NSLog(@"shop");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
