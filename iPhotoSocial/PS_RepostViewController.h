//
//  PS_RepostViewController.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-2.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PS_MediaModel.h"
#import "PS_InstragramModel.h"

typedef enum : NSUInteger {
    kComeFromServer,
    kComeFromInstragram,
} ComeFromType;

@interface PS_RepostViewController : UIViewController

@property (nonatomic, strong) PS_MediaModel *model;
@property (nonatomic, strong) PS_InstragramModel *insModel;

@property (nonatomic, assign) ComeFromType type;

@end
