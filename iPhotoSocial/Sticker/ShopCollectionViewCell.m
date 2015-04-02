//
//  ShopCollectionViewCell.m
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "ShopCollectionViewCell.h"
#define kWinWidth [UIScreen mainScreen].bounds.size.width
#define kWinHeight [UIScreen mainScreen].bounds.size.height
@implementation ShopCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 55, 55)];
        self.imageview.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageview];
    }

    return self;
}
@end
