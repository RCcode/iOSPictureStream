//
//  ps_baseNavigationController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_BaseNavigationController.h"

@interface PS_BaseNavigationController ()

@end

@implementation PS_BaseNavigationController

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        for (UIView *view in self.subviews) {
//            if ([view isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
//                [view removeFromSuperview];
//            }
//        }
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationBar.translucent = NO;
//    self.navigationBar.backgroundColor = [UIColor clearColor];/
//    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"a"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;

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
