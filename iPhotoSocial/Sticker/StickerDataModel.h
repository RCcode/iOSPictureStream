//
//  StickerDataModel.h
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StickerDataModel : NSObject
//id
//name
//url
//lUrl
//zipUrl
//zipMd5
//updateTime
//size
//price
@property (nonatomic,assign) int stickerId;
@property (nonatomic,strong) NSString *stickerName;
@property (nonatomic,strong) NSString *stickerUrlString;
@property (nonatomic,strong) NSString *stickerSmallUrlString;
@property (nonatomic,strong) NSString *stickerZipUrlString;
@property (nonatomic,strong) NSString *stickerMd5String;
@property (nonatomic,assign) long stickerDownloadTime;
@property (nonatomic,assign) long stickerSize;
@property (nonatomic,strong) NSString *stickerPrice;
@property (nonatomic,assign) int stickerIsLooked;
@property (nonatomic,strong) NSString *localDir;

@end
