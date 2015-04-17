//
//  PS_ImageDetailViewCell.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-26.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PS_MediaModel.h"
#import "PS_InstragramModel.h"

@interface PS_ImageDetailViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *theImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *usernameButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *appIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *appLabel;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *appButton;
@property (weak, nonatomic) IBOutlet UIButton *likesListButton;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;//视频下载时转圈
@property (nonatomic, strong) AVPlayer *av;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) PS_MediaModel *model;
@property (nonatomic, strong) PS_InstragramModel *instragramModel;

@end
