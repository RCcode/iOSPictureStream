//
//  DownloadManageCell.m
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/3.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "DownloadManageCell.h"
@implementation DownloadManageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.bannerView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 135)];
        self.bannerView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.bannerView];
        self.deleteView = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteView.frame = CGRectMake(256, 91, 44, 44);
        
        //        self.deleteView = [[UIImageView alloc] initWithFrame:CGRectMake(256, 91, 44, 44)];
        [self.deleteView setImage:[UIImage imageNamed:@"s_delete"] forState:UIControlStateNormal];
        self.deleteView.backgroundColor = colorWithHexString(@"#5cbc99");
        [self.bannerView addSubview:self.deleteView];
    }
    return self;
}

- (void)setDeleteButtonTarget:(id)target andSelector:(SEL)seletor
{
    [self.deleteView addTarget:target action:seletor forControlEvents:UIControlEventTouchUpInside];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

