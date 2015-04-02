//
//  CMethods.h
//  TaxiTest
//
//  Created by Xiaohui Guo  on 13-3-13.
//  Copyright (c) 2013年 FJKJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#import <UIKit/UIKit.h>

@interface PS_CMethods : NSObject
{
    
}

NSArray* getImagesArray(NSString *folderName, NSString *type);

UIImage* getImageFromDirectory(NSString *imageName, NSString *folderName);
//window 高度
CGFloat windowHeight();

//window 宽度
CGFloat windowWidth();

//statusBar隐藏与否的高
CGFloat heightWithStatusBar();

//view 高度
CGFloat viewHeight(UIViewController *viewController);

//图片路径
UIImage* pngImagePath(NSString *name);
UIImage* jpgImagePath(NSString *name);
NSString* jpgImagePathWithPath(NSString *name);

//数字转化为字符串
NSString* stringForInteger(int value);

//系统语言环境
NSString* currentLanguage();

BOOL iPhone4();
BOOL iPhone5();

BOOL IOS7();
BOOL IOS8();
//返回随机不重复树
NSMutableArray* randrom(int count,int totalCount);

//十六进制颜色值
UIColor* colorWithHexString(NSString *stringToConvert);

//把字典转化为json串
NSData* toJSONData(id theData);

//转换时间戳
NSString *exchangeTime(NSString *time);

//美工px尺寸，转ios字体size（接近值）
CGFloat fontSizeFromPX(CGFloat pxSize);

NSString *appVersion();

NSString *LocalizedString(NSString *translation_key, id none);

NSString *doDevicePlatform();

CGSize sizeWithContentAndFont(NSString *content,CGSize size,float fontSize);

void cancleAllRequests();

//void refreshAppInfoArray(NSMutableArray *array);

//根据内容和字体获得标签大小
CGRect getTextLabelRectWithContentAndFont(NSString *content,UIFont *font);



@end
