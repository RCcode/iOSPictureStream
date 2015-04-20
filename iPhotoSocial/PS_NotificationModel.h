//
//  PS_NotificationModel.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-30.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    NotiTypeNone = -1,
    NotiTypeFollow,    //获得follow
    NotiTypeLike,      //获得like
    NotiTypeHot,       //上推荐
    NotiTypeSticker,   //新贴纸
    NotiTypeBackGround,//新背景
} NotiType;

@interface PS_NotificationModel : NSObject<NSCoding>

@property (nonatomic, assign) NotiType  type;    //通知分类
@property (nonatomic, strong) NSString *mediaId; //当type为1,2时生效:媒体id
@property (nonatomic, strong) NSString *likes;   //当type为1,2时生效:Like数量
@property (nonatomic, strong) NSString *liked;   //当type为1时生效:被Like数量
@property (nonatomic, strong) NSString *tag;     //当type为1,2时生效:Tag标签
@property (nonatomic, strong) NSString *packName;//当type为1,2时生效:android为包名,ios为appid格式为:android|ios.不同
                                                 //平台截取字符串
@property (nonatomic, strong) NSString *downUrl; //当type为1,2时生效:下载短地址
@property (nonatomic, strong) NSString *uid;     //当type为0时生效:用户id
@property (nonatomic, strong) NSString *userName;//当type为0时生效:用户名
@property (nonatomic, strong) NSString *pic;     //当type为0时生效:用户头像
@property (nonatomic, assign) double    time;    //推送时间
@property (nonatomic, strong) NSString *backup;  //备用字段

@end
