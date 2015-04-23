//
//  PS_UserInfoReusableView.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-21.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_UserInfoReusableView.h"

@implementation PS_UserInfoReusableView

- (void)awakeFromNib {
    // Initialization code
    _userImage.layer.cornerRadius = 60/2.0;
    _userImage.layer.masksToBounds = YES;
}

- (IBAction)followBtnClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(followBtnClick:)]) {
        [_delegate followBtnClick:sender];
    }
}

- (IBAction)likesClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(likesClick)]) {
        [_delegate likesClick];
    }
}

- (IBAction)followsClick:(UIButton *)sende{
    if ([_delegate respondsToSelector:@selector(followsClick)]) {
        [_delegate followsClick];
    }
}


@end
