//
//  PS_MediaModel.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-30.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_MediaModel.h"

@implementation PS_MediaModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    
    if (value ==nil || [value isKindOfClass:[NSNull class]]) {
        [self setValue:@"" forKey:key];
        if ([key isEqualToString:@"id"]) {
            [self setValue:@0 forKey:key];
        }
        return;
    }
    
    if ([key isEqualToString:@"id"]) {
        _compare_id = [value integerValue];
    }
    
    if ([key isEqualToString:@"uid"]) {
        _uid = [NSString stringWithFormat:@"%@",value];
    }
    
    if ([key isEqualToString:@"mediaType"]) {
        _mediaType = [NSString stringWithFormat:@"%@",value];
    }
}

@end
