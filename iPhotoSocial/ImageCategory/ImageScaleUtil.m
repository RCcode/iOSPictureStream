//
//  ImageScaleUtil.m
//  OpenCVTest
//
//  Created by MAXToooNG on 14-5-15.
//  Copyright (c) 2014年 MAXToooNG. All rights reserved.
//

#import "ImageScaleUtil.h"

@implementation ImageScaleUtil

+ (CGPoint)getThePointWithImage:(CGPoint)p imageSize:(CGSize)size
{
    
    CGPoint resultPoint = {0,0};
    
    //    resultPoint.x = p.x * [ImageScaleUtil getTheScaleForImageSize:size];
    //    resultPoint.y = p.y * [ImageScaleUtil getTheScaleForImageSize:size];
    return resultPoint;
}

+ (CGFloat)getTheScaleForImageSize:(CGSize)size originalSize:(CGSize)oriSize
{
    CGFloat width = oriSize.width;
    CGFloat height = oriSize.height;
    CGFloat scale = 1.0f;
    
    if (size.width > size.height)
    {
        scale = size.width/width;
        
    }else{
        if (size.width / size.height < width / height)
        {
            scale = size.height/height ;
        }else{
            scale = size.width/width ;
        }
    }
    NSLog(@"scale = %f",scale);
    return scale;
}

@end
