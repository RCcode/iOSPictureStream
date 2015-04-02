//
//  PS_StoreViewController.h
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/4/1.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum PS_ShopType
{
    kPSStickerShop,
    kPSBackgroundShop
}PS_ShopType;
@interface PS_StoreViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign) PS_ShopType type;

@end
