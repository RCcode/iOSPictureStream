//
//  DownloadManageCell.h
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/3.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadManageCell : UITableViewCell
@property (nonatomic,strong) UIImageView *bannerView;
@property (nonatomic,strong) UIButton *deleteView;

- (void)setDeleteButtonTarget:(id)target andSelector:(SEL)seletor;

@end
