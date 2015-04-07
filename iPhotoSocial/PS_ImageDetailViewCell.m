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
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.av];
    _playerLayer.backgroundColor = [UIColor greenColor].CGColor;
    _playerLayer.frame = _theImageView.frame;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    [self.contentView.layer addSublayer:_playerLayer];
}

//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//    _playerLayer.frame = _theImageView.frame;
//}

//发现页赋值
-(void)setModel:(PS_MediaModel *)model
{
    _model = model;
    _descLabel.text = model.media_desc;
    _likeCountLabel.text = [NSString stringWithFormat:@"%@",model.likes];
    [_theImageView sd_setImageWithURL:[NSURL URLWithString:model.media_pic] placeholderImage:[UIImage imageNamed:@"a"]];
    _appLabel.text = model.tag;
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:@"a"]];
    [_usernameButton setTitle:model.username forState:UIControlStateNormal];
    
    [_playerLayer removeFromSuperlayer];
}

//推荐页赋值
-(void)setHotModel:(PS_MediaModel *)hotModel
{
    _hotModel = hotModel;
    _descLabel.text = hotModel.media_desc;
    _likeCountLabel.text = [NSString stringWithFormat:@"%@",hotModel.likes];
    [_theImageView sd_setImageWithURL:[NSURL URLWithString:hotModel.media_url] placeholderImage:[UIImage imageNamed:@"a"]];
    _appLabel.text = hotModel.tag;
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:hotModel.pic] placeholderImage:[UIImage imageNamed:@"a"]];
    [_usernameButton setTitle:hotModel.username forState:UIControlStateNormal];
}

-(void)setInstragramModel:(PS_InstragramModel *)instragramModel
{
    _instragramModel = instragramModel;
    _descLabel.text = instragramModel.desc;
    _likeCountLabel.text = instragramModel.likes;
    [_theImageView sd_setImageWithURL:[NSURL URLWithString:instragramModel.images[@"standard_resolution"][@"url"]] placeholderImage:[UIImage imageNamed:@"a"]];
//    _appLabel.text = instragramModel.tag;
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:instragramModel.profile_picture] placeholderImage:[UIImage imageNamed:@"a"]];
    [_usernameButton setTitle:instragramModel.username forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
