//
//  PS_ImageDetailViewCell.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-26.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_ImageDetailViewCell.h"

@implementation PS_ImageDetailViewCell

static CGFloat a;
- (void)awakeFromNib {
    
    NSLog(@"sss");
    // Initialization code
    
    a = CGRectGetMaxY(_myImageView.frame);
    
    NSString *str= [[NSBundle mainBundle] pathForResource:@"test" ofType:@"3gp"];
    NSURL *url = [NSURL fileURLWithPath:str];
    _mp = [[MPMoviePlayerController alloc] initWithContentURL:url];
    CGRect rect = self.myImageView.frame;
    _mp.view.frame = rect;
    _mp.backgroundView.backgroundColor = [UIColor greenColor];
    _mp.repeatMode = MPMovieRepeatModeOne;
    _mp.controlStyle = MPMovieControlStyleNone;
    _mp.scalingMode = MPMovieScalingModeAspectFill;
    [self.contentView addSubview:_mp.view];
    
//    _av = [AVPlayer playerWithPlayerItem:nil];
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.av];
//    playerLayer.backgroundColor = [UIColor clearColor].CGColor;
//    playerLayer.frame = self.myImageView.frame;
//    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    [self.contentView.layer addSublayer:playerLayer];
}

-(void)setModel:(TestModel *)model
{
    if (model.type == 2) {
//        self.myImageView.hidden = YES;
//        _mp.view.hidden = NO;
//        NSString *str= [[NSBundle mainBundle] pathForResource:@"test" ofType:@"3gp"];
//        NSURL *sourceMovieURL = [NSURL fileURLWithPath:str];
//        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
//        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//        [_av replaceCurrentItemWithPlayerItem:playerItem];
        
        NSString *str= [[NSBundle mainBundle] pathForResource:@"test" ofType:@"3gp"];
        NSURL *url = [NSURL fileURLWithPath:str];
        _mp.contentURL = url;
    }else{
//        _mp.view.hidden = YES;
//        _myImageView.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
