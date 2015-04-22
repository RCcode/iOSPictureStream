//
//  PS_UserViewCell.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-20.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_UserViewCell.h"
#import "UIImageView+WebCache.h"

@implementation PS_UserViewCell

- (void)awakeFromNib {
    // Initialization code
    _userImageView.layer.cornerRadius = 37/2;
    _userImageView.layer.masksToBounds = YES;
}


-(void)setNotiModel:(PS_NotificationModel *)notiModel
{
    _notiModel = notiModel;
    
    switch (notiModel.type) {
        case NotiTypeBackGround:
            _userNameLabel.text = LocalizedString(@"ps_noti_new_background", nil);
            break;
        case NotiTypeLike:{
            [_userImageView sd_setImageWithURL:[NSURL URLWithString:notiModel.pic] placeholderImage:[UIImage imageNamed:@"mr_head"]];
            NSString *str = LocalizedString(@"ps_noti_get_like", nil);
            _userNameLabel.text = [str stringByReplacingOccurrencesOfString:@"xx" withString:notiModel.liked];
            break;
        }
        case NotiTypeFollow:{
            [_userImageView sd_setImageWithURL:[NSURL URLWithString:notiModel.pic] placeholderImage:[UIImage imageNamed:@"mr_head"]];
            NSString *str = LocalizedString(@"ps_noti_start_follow", nil);
            _userNameLabel.text = [str stringByReplacingOccurrencesOfString:@"xx" withString:notiModel.userName];
            break;
        }
        case NotiTypeHot:
            _userNameLabel.text = LocalizedString(@"ps_noti_photo_featured", nil);
            break;
        case NotiTypeSticker:
            _userNameLabel.text = LocalizedString(@"ps_noti_new_sticker", nil);
        default:
            break;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
