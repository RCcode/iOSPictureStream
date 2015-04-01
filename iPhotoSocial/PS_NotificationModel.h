//
//  PS_NotificationModel.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-30.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PS_NotificationModel : NSObject

@property (nonatomic, strong) NSString *notiId;  //通知id
@property (nonatomic, strong) NSString *desc;//描述
@property (nonatomic, strong) NSString *time;//推送时间

@end
