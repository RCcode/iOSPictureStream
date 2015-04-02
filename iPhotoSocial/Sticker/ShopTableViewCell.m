//
//  ShopTableViewCell.m
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "ShopTableViewCell.h"

@implementation ShopTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.bannerView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 135)];
        [self addSubview:self.bannerView];
        self.bannerView.contentMode = UIViewContentModeScaleAspectFit;
        self.bannerView.userInteractionEnabled = YES;
        self.tagView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 33, 33)];
        self.tagView.image = [UIImage imageNamed:@"new"];
        [self addSubview:self.tagView];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
