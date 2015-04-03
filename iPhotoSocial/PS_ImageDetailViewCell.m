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

    _av = [AVPlayer playerWithPlayerItem:nil];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.av];
    _playerLayer.backgroundColor = [UIColor greenColor].CGColor;
    _playerLayer.frame = _theImageView.frame;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.contentView.layer addSublayer:_playerLayer];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _playerLayer.frame = _theImageView.frame;
}

-(void)setModel:(PS_MediaModel *)model
{
    _model = model;
    _descLabel.text = model.media_desc;
    _likeCountLabel.text = [NSString stringWithFormat:@"%ld",model.likes];
    [_theImageView sd_setImageWithURL:[NSURL URLWithString:model.media_url] placeholderImage:[UIImage imageNamed:@"a"]];
    _appLabel.text = model.tag;
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:@"a"]];
    [_usernameButton setTitle:model.username forState:UIControlStateNormal];
    
    if (model.type == 2) {
//        self.myImageView.hidden = YES;
        _playerLayer.hidden = NO;

    }else{
//        self.myImageView.hidden = NO;
        _playerLayer.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
