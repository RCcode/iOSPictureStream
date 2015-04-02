//
//  DownloadManageViewController.h
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/3.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopViewController.h"
@interface DownloadManageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic,assign) shopType type;
@end
