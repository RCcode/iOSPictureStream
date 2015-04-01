//
//  PS_Public.h
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/3/25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#ifndef iPhotoSocial_PS_Public_h
#define iPhotoSocial_PS_Public_h

#define kWindowHeight [UIScreen mainScreen].bounds.size.height
#define kWindowWidth  [UIScreen mainScreen].bounds.size.width

#define kTabBarHeight 49
#define kNavHeight 44
#define kSystemVersion [[UIDevice currentDevice] systemVersion].floatValue
#define kStatusBarHeight kSystemVersion>=7.0?20:0

#define kEditFrameHeight (kWindowHeight - kTabBarHeight - kNavHeight - (kStatusBarHeight))

#endif
