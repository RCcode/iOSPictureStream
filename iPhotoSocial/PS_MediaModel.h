//
//  PS_MediaModel.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-30.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PS_MediaModel : NSObject

@property (nonatomic, strong) NSString *mediaId;   //媒体id
@property (nonatomic, strong) NSString *likes;     //like数量
@property (nonatomic, strong) NSString *tag;       //tag标签
@property (nonatomic, strong) NSString *mediaPic;  //图片地址(发现页)
@property (nonatomic, strong) NSString *mediaUrl;  //视频媒体路径,仅对视频有效
@property (nonatomic, strong) NSString *uid;       //用户id
@property (nonatomic, strong) NSString *userName;  //用户名
@property (nonatomic, strong) NSString *pic;       //用户头像
@property (nonatomic, strong) NSString *mediaDesc; //描述
@property (nonatomic, strong) NSString *mediaType; //媒体类型:0.图片;1.视频
@property (nonatomic, strong) NSString *packName;  //android为包名,ios为appid格式为:android|ios.
@property (nonatomic, strong) NSString *downUrl;   //下载短地址

@property (nonatomic, assign) NSInteger compare_id;//用于分页

@end
