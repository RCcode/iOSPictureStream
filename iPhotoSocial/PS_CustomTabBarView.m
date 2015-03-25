//
//  PS_CustomTabBarView.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_CustomTabBarView.h"

@implementation PS_CustomTabBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        CGFloat btnWidth = frame.size.width / 5;
        CGFloat btnHeight = frame.size.height;
        
        for (int i = 0; i < 5; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * btnWidth, 0, btnWidth, btnHeight)];
            button.tag = i;
            [button setTitle:@"title" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:button];
        }
    }
    return self;
}


- (void)buttonOnClick:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(tabBarButtonClickWithIndex:)]) {
        [_delegate tabBarButtonClickWithIndex:button.tag];
    }
}

@end
