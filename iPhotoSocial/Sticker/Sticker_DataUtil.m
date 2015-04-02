//
//  DataUtil.m
//  BeautyCameraDemo
//
//  Created by MAXToooNG on 14-5-16.
//  Copyright (c) 2014年 MAXToooNG. All rights reserved.
//

#import "Sticker_DataUtil.h"

@implementation Sticker_DataUtil
static Sticker_DataUtil *dataUtil = nil;


+ (Sticker_DataUtil *)defaultDateUtil{
    if (dataUtil == nil) {
        dataUtil = [[Sticker_DataUtil alloc] init];
        dataUtil.unDownloadStickerModelArray = [[NSMutableArray alloc] init];
    }
    return dataUtil;
}

@end
