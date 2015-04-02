//
//  ShopViewController.h
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum shopType
{
    kStickerShop,
    kBackgroundShop
}shopType;

@protocol StickerDelegate <NSObject>

- (void)stickerCallback:(NSURL *)url;

@end

@interface ShopViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,assign) id<StickerDelegate> delegate;
@property (nonatomic,assign) shopType type;
@end
