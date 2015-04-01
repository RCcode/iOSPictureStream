//
//  PS_UserModel.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-30.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PS_UserModel : NSObject

@property (nonatomic, strong) NSString *uid;      //用户id
@property (nonatomic, strong) NSString *username; //用户名
@property (nonatomic, strong) NSString *pic;      //用户头像

@end