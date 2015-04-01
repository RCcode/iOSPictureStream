//
//  PS_ImageDetailViewCell.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-26.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PS_MediaModel.h"

@interface PS_ImageDetailViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *desclabel;
@property (weak, nonatomic) IBOutlet UIButton *userButton;

@property (nonatomic, strong) AVPlayer *av;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) PS_MediaModel *model;

@end
