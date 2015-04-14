//
//  ViewController.m
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/3/24.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "ViewController.h"
#import "PS_StoreViewController.h"
#import "ImageScaleUtil.h"
#import "UIImageEffects.h"
@interface ViewController ()
{
    UIImageView *_headImageView;
    UIImageView *_backgroundView;
    UIButton *_blurBtn;
    UIImageView *_blurView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _blurView.frame = self.view.bounds;
    _blurView.alpha = 0;

    
//    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurBtn = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [_blurBtn setFrame:CGRectMake(0, 0, 200, 50)];
    _blurBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 200);
    [self.view addSubview:_blurBtn];
    [_blurBtn addTarget:self action:@selector(blurScreen:) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *image = [UIImage imageNamed:@"headImage.png"];
//    UIImage *blurImage = [UIImageEffects imageByApplyingLightEffectToImage:image];
    UIImage *blurImage = [UIImageEffects blurImage:image withRadius:[NSNumber numberWithFloat:6.0]] ;
    _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 200)];
    _backgroundView.image = blurImage;
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundView.clipsToBounds = YES;
//    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    [blurView setFrame:_backgroundView.bounds];
//    [_backgroundView addSubview:blurView];
    [self.view addSubview:_backgroundView];
    
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 80, 80, 80)];
    [_backgroundView addSubview:_headImageView];
    _headImageView.backgroundColor = [UIColor blackColor];
    [_headImageView.layer setCornerRadius:40];
    _headImageView.layer.masksToBounds = YES;
    _headImageView.image = image;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Store" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 300, 100, 50)];
//    button.center = self.view.center;
    [self.view addSubview:button];
    [button addTarget:self action:@selector(intentToStore) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_blurView];
}

- (void)blurScreen:(UIButton *)btn
{
    
}

- (void)intentToStore
{
    PS_StoreViewController *store = [[PS_StoreViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:store];
    [self presentViewController:nav animated:YES completion:nil];

}

- (UIImage *)imageFromView:(UIView *)theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
