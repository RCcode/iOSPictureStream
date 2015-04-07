//
//  PS_ImageDetailViewController.h
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PS_MediaModel.h"
#import "PS_InstragramModel.h"

@interface PS_ImageDetailViewController : UIViewController

@property (nonatomic, strong) PS_MediaModel *model;

@property (nonatomic, strong) PS_InstragramModel *instragramModel;

@end
