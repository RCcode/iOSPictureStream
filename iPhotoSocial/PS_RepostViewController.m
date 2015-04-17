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
        NSLog(@"_userName = %@",_userName);
        [_imageView sd_setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        [self.view addSubview:_imageView];
    }
    _waterView = [[PS_RepostWaterView alloc] initWithHeadUrlString:_headImageUrl oriName:_userName andCenter:CGPointMake(kWindowWidth / 2, kWindowWidth - 30 / 2) andStyle:kRepostBottom];
    [_imageView addSubview:_waterView];
}

- (void)initNavigationBar
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    imageView.image = [UIImage imageNamed:@"repost.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
    if (self.type == kComeFromInstragram) {
        _isMedia = [self.insModel.type isEqualToString:@"video"];
    }else if (self.type == kComeFromServer){
//        _isMedia = [self.mModel.mediaType == ]
    }

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
