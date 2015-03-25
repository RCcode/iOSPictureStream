//
//  PS_ImageCollectionViewCell.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_ImageCollectionViewCell.h"

@interface PS_ImageCollectionViewCell  ()

@property (nonatomic,strong)UIImageView *imageView;

@end

@implementation PS_ImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

-(void)setimage:(UIImage *)image
{
    _imageView.image = image;
}

@end
