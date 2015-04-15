//
//  PS_NotificationModel.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-30.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_NotificationModel.h"

@implementation PS_NotificationModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    
    if (value ==nil || [value isKindOfClass:[NSNull class]]) {
        [self setValue:@"" forKey:key];
        if ([key isEqualToString:@"type"] || [key isEqualToString:@"time"]) {
            [self setValue:@-1 forKey:key];
        }
        return;
    }
    
    if ([key isEqualToString:@"type"]) {
        _type = [value integerValue];
    }
    
    if ([key isEqualToString:@"time"]) {
        _time = [value doubleValue];
    }
}

@end
