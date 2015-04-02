//
//  PS_ImageDetailViewCell.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-26.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_ImageDetailViewCell.h"

@implementation PS_ImageDetailViewCell

- (void)awakeFromNib {
    // Initialization code

    _av = [AVPlayer playerWithPlayerItem:nil];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.av];
    _playerLayer.backgroundColor = [UIColor greenColor].CGColor;
    _playerLayer.frame = self.theImageView.frame;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.contentView.layer addSublayer:_playerLayer];
}

-(void)setModel:(PS_MediaModel *)model
{
    _model = model;
    self.descLabel.text = model.desc;
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
