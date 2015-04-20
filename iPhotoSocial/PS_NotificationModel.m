//
//  PS_NotificationModel.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-3-30.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_NotificationModel.h"

@implementation PS_NotificationModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_type forKey:@"type"];
    [aCoder encodeObject:_mediaId forKey:@"mediaId"];
    [aCoder encodeObject:_likes forKey:@"likes"];
    [aCoder encodeObject:_liked forKey:@"liked"];
    [aCoder encodeObject:_tag forKey:@"tag"];
    [aCoder encodeObject:_packName forKey:@"packName"];
    [aCoder encodeObject:_downUrl forKey:@"downUrl"];
    [aCoder encodeObject:_uid forKey:@"uid"];
    [aCoder encodeObject:_userName forKey:@"userName"];
    [aCoder encodeObject:_pic forKey:@"pic"];
    [aCoder encodeDouble:_time forKey:@"time"];
    [aCoder encodeObject:_backup forKey:@"backup"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _type = [aDecoder decodeIntegerForKey:@"type"];
        _mediaId = [aDecoder decodeObjectForKey:@"mediaId"];
        _likes = [aDecoder decodeObjectForKey:@"likes"];
        _liked = [aDecoder decodeObjectForKey:@"liked"];
        _tag = [aDecoder decodeObjectForKey:@"tag"];
        _packName = [aDecoder decodeObjectForKey:@"packName"];
        _downUrl = [aDecoder decodeObjectForKey:@"downUrl"];
        _uid = [aDecoder decodeObjectForKey:@"uid"];
        _userName = [aDecoder decodeObjectForKey:@"userName"];
        _pic = [aDecoder decodeObjectForKey:@"pic"];
        _time = [aDecoder decodeDoubleForKey:@"time"];
        _backup = [aDecoder decodeObjectForKey:@"backup"];
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    
    if (value ==nil || [value isKindOfClass:[NSNull class]]) {
        if ([key isEqualToString:@"type"] || [key isEqualToString:@"time"] || [key isEqualToString:@"liked"]) {
            [self setValue:@-1 forKey:key];
        }else{
            [self setValue:@"" forKey:key];
        }
        return;
    }
    
    if ([key isEqualToString:@"type"]) {
        _type = [value integerValue];
    }
    
    if ([key isEqualToString:@"time"]) {
        _time = [value doubleValue];
    }
    
    if ([key isEqualToString:@"liked"]) {
        _liked = [value stringValue];
    }
}

@end
