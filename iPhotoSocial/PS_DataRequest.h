//
//  PS_DataRequest.h
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/3/26.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PS_DataRequest : NSObject
@property (nonatomic,retain) NSMutableData *downloadData;

@property (nonatomic,copy) NSString *requestString;

@property (nonatomic,assign) id target;

@property (nonatomic,assign) SEL action;
@property (nonatomic,assign) NSInteger tag;

+ (PS_DataRequest *)getRequestWithUrlString:(NSString *)str target:(id)target action:(SEL)action tag:(NSInteger)tag;
+ (PS_DataRequest *)postRequestWithUrlString:(NSString *)str target:(id)target action:(SEL)action tag:(NSInteger)tag;
@end
