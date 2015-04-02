//
//  ShopButton.h
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopButton : UIButton
@property (nonatomic,strong) UIImageView *shopTag;
@property (nonatomic,assign,setter=setUse:) BOOL isUse;
- (void)setNewTagForButton;
- (void)setNewTagForBackground;
@end
