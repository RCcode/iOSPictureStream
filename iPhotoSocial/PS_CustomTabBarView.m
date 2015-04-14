//
//  PS_CustomTabBarView.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_CustomTabBarView.h"

@interface PS_CustomTabBarView ()
{
    UIButton *_customBtn;
}

@end

@implementation PS_CustomTabBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        CGFloat btnWidth = frame.size.width / 5;
        CGFloat btnHeight = frame.size.height;
        NSArray *images = @[@"nav_explore",@"nav_featured",@"nav_editor",@"nav-tongzhi",@"nav_profile"];
        NSArray *highLightimages = @[@"nav_explore_h",@"nav_featured_h",@"nav_editor",@"nav-tongzhi_h",@"nav_profile_h"];
        for (int i = 0; i < 5; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * btnWidth, 0, btnWidth, btnHeight)];
            button.tag = i;
            [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:highLightimages[i]] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:button];
        }
    }
    return self;
}

- (void)buttonOnClick:(UIButton *)button
{
    if (_customBtn != button) {
        _customBtn.selected = NO;
        button.selected = YES;
        _customBtn = button;
    }
    if ([_delegate respondsToSelector:@selector(tabBarButtonClickWithIndex:)]) {
        [_delegate tabBarButtonClickWithIndex:button.tag];
    }
}

@end
