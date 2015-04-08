//
//  ViewController.m
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/3/24.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "ViewController.h"
#import "PS_StoreViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Store" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 200, 100, 50)];
    button.center = self.view.center;
    [self.view addSubview:button];
    [button addTarget:self action:@selector(intentToStore) forControlEvents:UIControlEventTouchUpInside];
}

- (void)intentToStore
{
    PS_StoreViewController *store = [[PS_StoreViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:store];
    [self presentViewController:nav animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
