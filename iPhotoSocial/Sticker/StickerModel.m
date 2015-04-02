//
//  StickerModel.m
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "StickerModel.h"

@implementation StickerModel
- (instancetype)init
{
    if (self = [super init]) {
        self.preview = [UIImage imageNamed:@"sticker1"];
        self.urlArray = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
