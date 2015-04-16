//
//  PS_ImageDetailViewCell.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-26.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_ImageDetailViewCell.h"
#import "UIImageView+WebCache.h"

@implementation PS_ImageDetailViewCell

- (void)awakeFromNib {
    // Initialization code

    NSLog(@"sss");
    _av = [AVPlayer playerWithPlayerItem:nil];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_av];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.contentView.layer addSublayer:_playerLayer];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _playerLayer.frame = _theImageView.frame;
}

//发现页和推荐页赋值
-(void)setModel:(PS_MediaModel *)model
{
    NSLog(@"model.type = %ld",model.mediaType);
    _model = model;
    _descLabel.text = model.mediaDesc;
    _likeCountLabel.text = model.likes;
    [_theImageView sd_setImageWithURL:[NSURL URLWithString:model.mediaPic] placeholderImage:[UIImage imageNamed:@"a"]];
    _appLabel.text = model.tag;
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:@"a"]];
    [_usernameButton setTitle:model.userName forState:UIControlStateNormal];
    
    if (model.mediaType == MediaTypeVideo) {
        _playerLayer.hidden = NO;
        NSLog(@"%@",model.mediaUrl);
//        AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:model.mediaUrl]];
//        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
//        [_av replaceCurrentItemWithPlayerItem:item];
//        [_av play];
    }else{
        _playerLayer.hidden = YES;
    }
}

//个人页赋值
-(void)setInstragramModel:(PS_InstragramModel *)instragramModel
{
    _instragramModel = instragramModel;
    _descLabel.text = instragramModel.desc;
    _likeCountLabel.text = instragramModel.likesCount;
    [_theImageView sd_setImageWithURL:[NSURL URLWithString:instragramModel.images[@"standard_resolution"][@"url"]] placeholderImage:[UIImage imageNamed:@"a"]];
    _appLabel.text = @"rcnocrop";
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:instragramModel.profile_picture] placeholderImage:[UIImage imageNamed:@"a"]];
    [_usernameButton setTitle:instragramModel.username forState:UIControlStateNormal];
    
    if ([instragramModel.type isEqualToString:@"video"]) {
        _playerLayer.hidden = NO;
    }else{
        _playerLayer.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
