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
        if ([key isEqualToString:@"id"] || [key isEqualToString:@"mediaType"] || [key isEqualToString:@"likes"]) {
            [self setValue:@-1 forKey:key];
        }else{
            [self setValue:@"" forKey:key];
        }
        return;
    }
    
    if ([key isEqualToString:@"id"]) {
        _compare_id = [value integerValue];
    }
    
    if ([key isEqualToString:@"mediaType"]) {
        _mediaType = [value integerValue];
    }
    
    if ([key isEqualToString:@"likes"]) {
        _likes = [value stringValue];
    }
    
    if ([key isEqualToString:@"uid"]) {
        _uid = [NSString stringWithFormat:@"%@",value];
    }
}

@end
