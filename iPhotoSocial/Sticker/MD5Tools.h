//
//  MD5Tools.h
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/2.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface MD5Tools : NSObject
+ (NSString*)getFileMD5WithPath:(NSString*)path;
@end
