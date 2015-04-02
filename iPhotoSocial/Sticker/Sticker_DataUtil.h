//
//  DataUtil.h
//  BeautyCameraDemo
//
//  Created by MAXToooNG on 14-5-16.
//  Copyright (c) 2014年 MAXToooNG. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "NCFilters.h"
//#import "GADInterstitial.h"
@interface Sticker_DataUtil : NSObject
+ (Sticker_DataUtil *)defaultDateUtil;


//@property (nonatomic,assign) NCFilterType globleFilterType;
@property (nonatomic ,strong) NSArray *stickerModelArray;
@property (nonatomic, strong) NSMutableArray *unDownloadStickerModelArray;


@end
