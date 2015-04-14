//
//  PS_UserinfoView.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-13.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_UserinfoView.h"

@implementation PS_UserinfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)followBtnClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(followBtnClick:)]) {
        [_delegate followBtnClick:sender];
    }
}

- (IBAction)likesClick:(UITapGestureRecognizer *)sender {
    if ([_delegate respondsToSelector:@selector(likesClick)]) {
        [_delegate likesClick];
    }
}

- (IBAction)followsClick:(UITapGestureRecognizer *)sende{
    if ([_delegate respondsToSelector:@selector(followsClick)]) {
        [_delegate followsClick];
    }
}

@end
