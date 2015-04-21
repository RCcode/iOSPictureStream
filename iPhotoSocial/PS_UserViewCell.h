//
//  PS_UserViewCell.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-20.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PS_NotificationModel.h"

@interface PS_UserViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *userDetailLabel;

@property (nonatomic, strong) PS_NotificationModel *notiModel;

@end
