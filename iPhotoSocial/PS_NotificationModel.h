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

@interface PS_NotificationModel : NSObject

@property (nonatomic, assign) NotiType  type;       //推送时间
@property (nonatomic, strong) NSString *mediaId;    //推送时间
@property (nonatomic, strong) NSString *likes;      //推送时间
@property (nonatomic, strong) NSString *liked;      //推送时间
@property (nonatomic, strong) NSString *tag;        //推送时间
@property (nonatomic, strong) NSString *packName;   //推送时间
@property (nonatomic, strong) NSString *downUrl;    //推送时间
@property (nonatomic, strong) NSString *uid;        //推送时间
@property (nonatomic, strong) NSString *userName;   //推送时间
@property (nonatomic, strong) NSString *pic;        //推送时间
@property (nonatomic, assign) double    time;        //推送时间
@property (nonatomic, strong) NSString *backup;     //推送时间

@end
