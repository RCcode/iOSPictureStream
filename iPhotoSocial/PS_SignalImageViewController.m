//
//  PS_SignalImageViewController.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-7.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_SignalImageViewController.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"

@interface PS_SignalImageViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *layer;

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation PS_SignalImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowWidth)];
    _imageView.center = self.view.center;
    [self.view addSubview:_imageView];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_model.images[@"standard_resolution"][@"url"]] placeholderImage:[UIImage imageNamed:@"mr_img"]];
    
    if ([_model.type isEqualToString:@"video"]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *directorPath = [documentPath stringByAppendingPathComponent:@"Download"];
        if (![fileManager fileExistsAtPath:directorPath]) {
            [fileManager createDirectoryAtPath:directorPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *pathStr = [directorPath stringByAppendingPathComponent:[[_model.videos[@"standard_resolution"][@"url"] componentsSeparatedByString:@"/"] lastObject]];
        if ([fileManager fileExistsAtPath:pathStr]) {
            [self playVideoWithFilePath:[NSURL fileURLWithPath:pathStr]];
        }else{
            //下载视频
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityView.frame = CGRectMake(_imageView.frame.size.width - 50, _imageView.frame.size.height - 50, 50, 50);
            [activityView startAnimating];
            [_imageView addSubview:activityView];
            
            _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            NSURL *url = [NSURL URLWithString:_model.videos[@"standard_resolution"][@"url"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSProgress *p = nil;
            
            NSURLSessionDownloadTask *task = [_manager downloadTaskWithRequest:request progress:&p destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return [NSURL fileURLWithPath:pathStr];
                
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                NSLog(@"---%@",filePath);
                [activityView stopAnimating];
                if (error) {
                    [PS_DataUtil showPromptWithText:LocalizedString(@"ps_download_failed", nil)];
                }else{
                    [self playVideoWithFilePath:filePath];
                }
            }];
            [_manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                NSLog(@"%f",(float)totalBytesWritten/(float)totalBytesExpectedToWrite);
            }];
            [task  resume];
        }
    }
}

- (void)playVideoWithFilePath:(NSURL *)filePath
{
    //播放视频
    AVAsset *assert =[AVAsset assetWithURL:filePath];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:assert];
    _player = [AVPlayer playerWithPlayerItem:item];
    _layer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _layer.frame = _imageView.frame;
    _layer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:_layer];
    [_player play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
}

- (void)itemDidFinishPlaying:(AVPlayerItem *)player;
{
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
