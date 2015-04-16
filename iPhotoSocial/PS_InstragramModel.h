//
//  PS_InstragramModel.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-3.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PS_InstragramModel : NSObject

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *media_id;
@property (nonatomic, strong) NSString *type;       //image or video
@property (nonatomic, strong) NSString *likes;      //like数

@property (nonatomic, strong) NSDictionary *images; // 图片地址
@property (nonatomic, strong) NSDictionary *videos; // 视频地址

@property (nonatomic, strong) NSString *username;   //作者名
@property (nonatomic, strong) NSString *profile_picture;//作者头像
@property (nonatomic, strong) NSString *uid;        //作者id

//需要从自己服务器获取
@property (nonatomic, strong) NSString *likesCount; //咱服务器的like数
@property (nonatomic, strong) NSString *packName;
@property (nonatomic, strong) NSString *downUrl;    //下载短地址

@property (nonatomic, strong) NSURL *localFilePath;//视频下载后的本地地址

//
//images =             {
//    "low_resolution" =                 {
//        height = 306;
//        url = "https://scontent.cdninstagram.com/hphotos-xaf1/t51.2885-15/s306x306/e15/11049429_1086121091401915_996103201_n.jpg";
//        width = 306;
//    };
//    "standard_resolution" =                 {
//        height = 640;
//        url = "https://scontent.cdninstagram.com/hphotos-xaf1/t51.2885-15/e15/11049429_1086121091401915_996103201_n.jpg";
//        width = 640;
//    };
//    thumbnail =                 {
//        height = 150;
//        url = "https://scontent.cdninstagram.com/hphotos-xaf1/t51.2885-15/s150x150/e15/11049429_1086121091401915_996103201_n.jpg";
//        width = 150;
//    };
//};



//"videos": {
//    "low_resolution": {
//        "url": "http://distilleryvesper9-13.ak.instagram.com/090d06dad9cd11e2aa0912313817975d_102.mp4",
//        "width": 480,
//        "height": 480
//    },
//    "standard_resolution": {
//        "url": "http://distilleryvesper9-13.ak.instagram.com/090d06dad9cd11e2aa0912313817975d_101.mp4",
//        "width": 640,
//        "height": 640
//    },
@end
