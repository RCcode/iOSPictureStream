//
//  PS_UserModel.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-30.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_UserModel.h"

@implementation PS_UserModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    
    if (value ==nil || [value isKindOfClass:[NSNull class]]) {
        if ([key isEqualToString:@"uid"]) {
            [self setValue:@-1 forKey:@"uid"];
        }else{
        [self setValue:@"" forKey:key];
        }
        return;
    }
    if ([key isEqualToString:@"uid"]) {
        _uid = [value integerValue];
    }
}

@end
