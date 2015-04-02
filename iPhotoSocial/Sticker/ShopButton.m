//
//  ShopButton.m
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "ShopButton.h"

@implementation ShopButton

- (void)setNewTagForButton{
    self.shopTag = [[UIImageView alloc] init];
    [self.shopTag setFrame:CGRectMake(38, 0, 18, 18)];
    self.shopTag.image = [UIImage imageNamed:@"s_new"];
    [self addSubview:self.shopTag];
    self.shopTag.hidden = YES;

}

- (void)setNewTagForBackground
{
    self.shopTag = [[UIImageView alloc] init];
    if (iPhone4()) {
        [self.shopTag setFrame:CGRectMake(27, 0, 18, 18)];
    }else{
        [self.shopTag setFrame:CGRectMake(57, 0, 18, 18)];
    }
    
    self.shopTag.image = [UIImage imageNamed:@"s_new"];
    [self addSubview:self.shopTag];
    self.shopTag.hidden = YES;
}

//- (void)setSelected:(BOOL)selected
//{
//    
//}

- (void)setUse:(BOOL)used
{
    _isUse = used;
    if (used == YES) {
        self.layer.borderWidth = 4;
        self.layer.borderColor = colorWithHexString(@"#5cbc99").CGColor;
    }else{
        self.layer.borderWidth = 0;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
