//
//  PS_UserinfoView.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-13.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserInfoViewDelegate <NSObject>

- (void)followBtnClick:(UIButton *)btn;
- (void)likesClick;
- (void)followsClick;

@end

@interface PS_UserinfoView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followsCountLabel;

@property (assign, nonatomic) id<UserInfoViewDelegate> delegate;

@end
