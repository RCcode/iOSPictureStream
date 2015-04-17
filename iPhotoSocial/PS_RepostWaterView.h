//
//  PS_RepostWaterView.h
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/4/17.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum RepostWaterStyle
{
    kRepostTop,
    kRepostBottom,
    kRepostLeft,
    kRepostRight
}RepostWaterStyle;

@interface PS_RepostWaterView : UIView

- (instancetype)initWithHeadUrlString:(NSString *)urlString oriName:(NSString *)userName andCenter:(CGPoint )center andStyle:(RepostWaterStyle)style;

@end
