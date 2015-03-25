//
//  PS_CustomTabBarView.h
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol tabBarDelegate <NSObject>

@optional
- (void)tabBarButtonClickWithIndex:(NSInteger)index;

@end

@interface PS_CustomTabBarView : UIView

@property (nonatomic,weak) id<tabBarDelegate> delegate;

@end
