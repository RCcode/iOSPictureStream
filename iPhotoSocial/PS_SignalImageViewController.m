//
//  PS_SignalImageViewController.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-7.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_SignalImageViewController.h"
#import "UIImageView+WebCache.h"

@interface PS_SignalImageViewController ()

@end

@implementation PS_SignalImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowWidth)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:[UIImage imageNamed:@"a"]];
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
