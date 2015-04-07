//
//  PS_InstragramModel.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-3.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_InstragramModel.h"

@implementation PS_InstragramModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"id"]) {
        _media_id = value;
    }
    
    if ([key isEqualToString:@"caption"]) {
        _desc = value[@"text"];
    }
    
    if ([key isEqualToString:@"user"]) {
        _username = value[@"username"];
        _uid = value[@"id"];
        _profile_picture = value[@"profile_picture"];
    }
}

@end
