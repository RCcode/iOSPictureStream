//
//  StickerModel.h
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "StickerDataModel.h"
@interface StickerModel : NSObject
@property (nonatomic,strong) NSMutableArray *urlArray;
@property (nonatomic,assign) int buttonTag;
@property (nonatomic,strong) UIImage *preview;
@property (nonatomic,assign) BOOL isLooked;
@property (nonatomic,strong) StickerDataModel *dataModel;
@end
