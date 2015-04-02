//
//  PS_MediaModel.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-30.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PS_MediaModel : NSObject

//发现
@property (nonatomic, strong) NSString *media_id;  //图片id
@property (nonatomic, assign) NSInteger likes;     //like数量
@property (nonatomic, strong) NSString *tag;       //tag标签
@property (nonatomic, strong) NSString *media_pic; //图片地址

//推荐
@property (nonatomic, strong) NSString *media_url; //图片地址
@property (nonatomic, strong) NSString *uid;       //用户id
@property (nonatomic, strong) NSString *username;  //用户名
@property (nonatomic, strong) NSString *pic;       //用户头像

@property (nonatomic, assign) NSInteger type;      //类型

//测试
@property (nonatomic, strong) NSString *media_desc;      //描述
@property (nonatomic, assign) NSInteger compare_id;


@end
