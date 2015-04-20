//
//  PS_Public.h
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/3/25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#ifndef iPhotoSocial_PS_Public_h
#define iPhotoSocial_PS_Public_h
#import "PS_CMethods.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "PS_DataRequest.h"
#import "UIImageView+WebCache.h"
#import "PS_DataUtil.h"
#define kWindowHeight [UIScreen mainScreen].bounds.size.height
#define kWindowWidth  [UIScreen mainScreen].bounds.size.width

#define kPSAppid 30038
#define kRedirectUri @"igd31c225c691d41b393394966b4b3ad2b://authorize"
#define kClientId @"d31c225c691d41b393394966b4b3ad2b"
#define kClientSecret @"187488efe23e46f7911bac4464c0ae6f"

#define kIsLogin @"isLogin"
#define kUid @"uid"
#define kUsername @"username"
#define kPic @"pic" 
#define kAccessToken @"accessToken"

//Test URL
#define kPSBaseUrl @"http://192.168.0.86:8082/RcSocialWeb/V1"
//Real URL
//#define kPSBaseUrl @"http://feed.rcplatformhk.com"

//注册用户信息
#define kPSRegistUserInfoUrl @"/user/registeUseInfo.do"
//获取图片列表
#define kPSGetRecommendMediaListUrl @"/media/getRecommendMediaList.do"
//发现图片列表
#define kPSGetExplorListUrl @"/media/getExplorList.do"
//更新用户 Follow Like 记录
#define kPSUpdateFollowUrl @"/user/updateFollow.do"
#define kPSUpdateLikeUrl @"/media/updateLike.do"
//获取用户following、followed列表
#define kPSGetFollowListUrl @"/user/getFollowList.do"
//获取图片用户like列表
#define kPSGetMediaLikeListUrl @"/media/getMediaLikeList.do"
//获取用户信息，like，follow数量
#define kPSGetUserLikeFollowUrl @"/user/getUserLikeFollow.do"
//插入用户分享图片
#define kPSInsertMediasUrl @"/media/insertMedias.do"
#define kPSGetLikesCountUrl @"/media/getMediaLikeCount.do"
//获取通知
#define kPSGetNoticeUrl @"/user/getNotice.do"
//贴纸小铺
#define kStickerMaxSid @"StickerMaxSid"
#define kBackgroundMaxSid @"BackgroundMaxSid"

#define CLIENT_ID	@"4e483786559e48bf912b7926843c074a"
#define CLIENT_SECRET @"5087a19a9b304fb0bb4ed836ff4e7ad4"


#define WEBSITE_URL	@"http://instagram.com/maxtooong"
#define REDIRECT_URI	@"http://"
#define ACCESS_TOKEN @"access_token"

#define HAVE_NEW_STICKER @"new_sticker"
#define HAVE_NEW_BACKGROUND @"new_background"

#define REQUSET_URL @"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=code&scope=likes"
#define SAMPLE_REQUEST @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token&scope=likes"

#endif
