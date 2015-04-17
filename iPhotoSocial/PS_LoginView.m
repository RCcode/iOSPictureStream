//
//  PS_LoginView.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-13.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_LoginView.h"

@implementation PS_LoginView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)labelText
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = colorWithHexString(@"#e95a5a");
        self.backgroundColor = [UIColor colorWithRed:233/255.0 green:90/255.0 blue:90/255.0 alpha:0.85];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, kWindowWidth-60-12-8.5, frame.size.height)];
        label.text = labelText;
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = colorWithHexString(@"#ffffff");
        label.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:label];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 8.5, 60, 27)];
        [button setBackgroundImage:[UIImage imageNamed:@"ic_login"] forState:UIControlStateNormal];
        [button setTitle:LocalizedString(@"", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}

- (void)loginBtnClick:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(login:)]) {
        [_delegate login:button];
    }
}

@end
