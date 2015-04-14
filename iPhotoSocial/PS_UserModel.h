//
//  PS_UserModel.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-30.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PS_UserModel : NSObject

@property (nonatomic, assign) NSInteger uid;      //用户id
@property (nonatomic, strong) NSString *userName; //用户名
@property (nonatomic, strong) NSString *pic;      //用户头像

@property (nonatomic, assign) NSInteger compareID;//用于分页

@end
