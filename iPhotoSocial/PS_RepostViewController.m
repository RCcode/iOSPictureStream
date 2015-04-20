//
//  PS_RepostViewController.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-2.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_RepostViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PS_RepostWaterView.h"

#define kRotateTag 300

@interface PS_RepostViewController ()
{
    NSString *_videoPath;
    NSString *_previewImageUrl;
    NSString *_imageUrl;
    NSString *_headImageUrl;
    NSString *_softIconUrl;
    NSString *_userName;
    BOOL _isMedia;
    PS_RepostWaterView *_waterView;
}
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) AVAudioPlayer *avPlayer;
@end

@implementation PS_RepostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self initNavigationBar];
    [self initView];
}

- (void)initView
{
    if (self.type == kComeFromInstragram) {
        _isMedia = [self.insModel.type isEqualToString:@"video"];
    }else if (self.type == kComeFromServer){
        //        _isMedia = [self.mModel.mediaType == ]
    }
    if (_isMedia) {
        
    }else{
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, kWindowWidth)];
        [self.view addSubview:_imageView];
        if (self.type == kComeFromInstragram) {
            _imageUrl = [self.insModel.images valueForKeyPath:@"standard_resolution.url"];
            _headImageUrl = self.insModel.profile_picture;
            _userName = self.insModel.username;
        }else if (self.type == kComeFromServer){
            _imageUrl = self.mModel.mediaPic;
            _headImageUrl = self.mModel.pic;
            _userName = self.mModel.userName;
        }
        _userName = @"what your name?";
        NSLog(@"_userName = %@",_userName);
        [_imageView sd_setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        [self.view addSubview:_imageView];
    }
   
    NSArray *titleName = [[NSArray alloc] initWithObjects:@"shuiyi_1",@"shuiyin_2",@"shuiyin_3",@"shuiyin_4", nil];
        for (int i = 0; i < titleName.count; i++) {
            UIButton *bottomBtn = [UIButton buttonWithType: UIButtonTypeCustom];
            [bottomBtn setBackgroundImage:[UIImage imageNamed:titleName[i]] forState:UIControlStateNormal];
            [bottomBtn addTarget:self action:@selector(switchRotate:) forControlEvents:UIControlEventTouchUpInside];
            [bottomBtn setTag:kRotateTag + i];
            [bottomBtn setFrame:CGRectMake(20 + (56 + 19) * i, (kWindowHeight - kWindowWidth ) / 2  + kWindowWidth, 56, 56)];
            [self.view addSubview:bottomBtn];
    }
    [self resetWaterView:CGPointMake(kWindowWidth / 2, kWindowWidth - 30 / 2) andStyle:kRepostBottom];
}

- (void)resetWaterView:(CGPoint)center andStyle:(RepostWaterStyle)style
{
    [_waterView removeFromSuperview];
    _waterView = [[PS_RepostWaterView alloc] initWithHeadUrlString:_headImageUrl oriName:_userName andCenter:center andStyle:style];
    [_imageView addSubview:_waterView];
}

- (void)switchRotate:(UIButton *)btn
{
    for (int i = 0; i < 4; i ++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:kRotateTag + i];
        button.selected = NO;
    }
    btn.selected = YES;
    switch (btn.tag) {
        case kRotateTag + 0:
        {
             [self resetWaterView:CGPointMake(kWindowWidth / 2, kWindowWidth - 30 / 2) andStyle:kRepostBottom];
        }
            break;
        case kRotateTag + 1:
        {
             [self resetWaterView:CGPointMake(kWindowWidth / 2, 30 / 2) andStyle:kRepostTop];
        }
            break;
        case kRotateTag +2:
        {
            [self resetWaterView:CGPointMake(30 / 2, kWindowWidth / 2) andStyle:kRepostLeft];
        }
            break;
        case kRotateTag + 3:
        {
            [self resetWaterView:CGPointMake(kWindowWidth - 30 / 2, kWindowWidth / 2) andStyle:kRepostRight];
        }
            break;
        default:
            break;
    }
}

- (void)initNavigationBar
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    imageView.image = [UIImage imageNamed:@"repost.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
   

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
