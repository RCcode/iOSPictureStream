//
//  PS_UserListTableViewController.h
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-2.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UserListTypeLike,
    UserListTypeFollow,
    UserListTypeFollowed,
} UserListType;

@interface PS_UserListTableViewController : UITableViewController

@property (nonatomic, assign) UserListType type;
@property (nonatomic, strong) NSString *uid;

@end
