//
//  PreviewViewController.h
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StickerDataModel.h"
#import "ShopViewController.h"
#import "ASProgressPopUpView.h"

@interface PreviewViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,ASProgressPopUpViewDelegate,UIAlertViewDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{
}
@property (nonatomic,strong) StickerDataModel *dataModel;
@property (nonatomic,assign) shopType type;
@end
