//
//  showBannerViewController.h
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopViewController.h"
@interface ShopBannerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,assign) shopType type;
@end
