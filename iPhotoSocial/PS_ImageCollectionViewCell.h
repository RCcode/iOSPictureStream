//
//  PS_ImageCollectionViewCell.h
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PS_MediaModel.h"
#import "PS_InstragramModel.h"

@interface PS_ImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UIImageView *tagImageView;
@property (nonatomic, strong) UIImageView *videoImageView;

@property (nonatomic, strong) PS_MediaModel *model;
@property (nonatomic, strong) PS_InstragramModel *instragramModel;

@end
