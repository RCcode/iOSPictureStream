//
//  PS_LoginView.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-13.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewDelegate <NSObject>

- (void)login:(UIButton *)button;

@end

@interface PS_LoginView : UIView

@property (nonatomic, weak) id<LoginViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)labelText;

@end
