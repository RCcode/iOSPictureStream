//
//  PS_UserViewCell.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-20.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_UserViewCell.h"

@implementation PS_UserViewCell

- (void)awakeFromNib {
    // Initialization code
    _userImageView.layer.cornerRadius = 37/2;
    _userImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
