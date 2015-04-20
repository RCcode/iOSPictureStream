//
//  DataUtil.m
//  BeautyCameraDemo
//
//  Created by MAXToooNG on 14-5-16.
//  Copyright (c) 2014年 MAXToooNG. All rights reserved.
//

#import "PS_DataUtil.h"

@implementation PS_DataUtil
static PS_DataUtil *dataUtil = nil;


+ (PS_DataUtil *)defaultDateUtil{
    if (dataUtil == nil) {
        dataUtil = [[PS_DataUtil alloc] init];
        dataUtil.c_teamArray = [[NSMutableArray alloc] init];
    }
    return dataUtil;
}

+ (void)showPromptWithText:(NSString *)text{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = text;
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:0.5];
}

@end
