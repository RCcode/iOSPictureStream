//
//  PS_ImageCollectionViewCell.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_ImageCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface PS_ImageCollectionViewCell  ()

@end

@implementation PS_ImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
        
        _videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 5 - 19, 5, 19, 14)];
        _videoImageView.image = [UIImage imageNamed:@"ic_video"];
        [self.contentView addSubview:_videoImageView];
        
//        _tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 20)];
//        _tagLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//        _tagLabel.textColor = [UIColor whiteColor];
//        _tagLabel.textAlignment = NSTextAlignmentCenter;
//        [self.contentView addSubview:_tagLabel];
        
        _tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 17.5, CGRectGetWidth(frame), 17.5)];
        _tagImageView.image = [UIImage imageNamed:@"biaoqian"];
        [self.contentView addSubview:_tagImageView];
    }
    return self;
}

- (void)setModel:(PS_MediaModel *)model
{
    _model = model;
    _tagImageView.hidden = YES;
    if ([model.mediaType isEqualToString:@"1"]) {
        _videoImageView.hidden = NO;
    }else{
        _videoImageView.hidden = YES;
    }
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.mediaPic] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error && error.code == 404) {
            NSLog(@"44444%@",model.mediaId);
            NSLog(@"图片已删除");
        }
    }];
}

-(void)setInstragramModel:(PS_InstragramModel *)instragramModel
{
    _instragramModel = instragramModel;
    
    if ([instragramModel.tags containsObject:@"rcnocrop"]) {
        _tagImageView.hidden = NO;
    }else{
        _tagImageView.hidden = YES;
    }
    
    if ([instragramModel.type isEqualToString:@"video"]) {
        _videoImageView.hidden = NO;
    }else{
        _videoImageView.hidden = YES;
    }

    [_imageView sd_setImageWithURL:[NSURL URLWithString:instragramModel.images[@"thumbnail"][@"url"]] placeholderImage:[UIImage imageNamed:@"a"]];
}

@end
