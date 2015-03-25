//
//  PS_TabBarViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_TabBarViewController.h"
#import "PS_CustomTabBarView.h"

@interface PS_TabBarViewController ()<tabBarDelegate>

@end

@implementation PS_TabBarViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    PS_CustomTabBarView *view = [[PS_CustomTabBarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 49)];
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
            self.selectedIndex = 0;
            self.title = @"0";
            break;
        case 1:
            self.selectedIndex = 1;
            self.title = @"1";
            break;
        case 2:
//            self.selectedIndex = 2;
            [self showEditView];
            break;
        case 3:
            self.selectedIndex = 2;
            self.title = @"2";
            break;
        case 4:
            self.selectedIndex = 3;
            self.title = @"3";
            break;
        default:
            break;
    }
}

- (void)showEditView
{
    CGFloat winWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat winHeight = [UIScreen mainScreen].bounds.size.height;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, winHeight - 200, winWidth, 200)];
    view.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
    [self.navigationController.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
