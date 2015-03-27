//
//  PS_ImageDetailViewCell.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-26.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface PS_ImageDetailViewCell : UITableViewCell

@property (nonatomic,strong) TestModel *model;

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *desclabel;

@property (nonatomic,strong) MPMoviePlayerController *mp;
@property (nonatomic,strong) AVPlayer *av;

@end
