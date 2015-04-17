//
//  PS_UserListTableViewController.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-2.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_UserListTableViewController.h"
#import "PS_UserModel.h"
#import "UIImageView+WebCache.h"

@interface PS_UserListTableViewController ()

@property (nonatomic, strong) NSMutableArray *userListArr;

@end

@implementation PS_UserListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userListArr = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSLog(@"_uid = %@",_uid);
    if (_type == UserListTypeFollow) {
        [self requestFollowUserList];
    }else{
        [self requestLikeUserList];
    }
}

- (void)requestFollowUserList
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetFollowListUrl];
    NSDictionary *params = @{@"appId":@(kPSAppid),
                             @"uid":_uid,
                             @"classify":@1};
    [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"7777777%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSArray *listArr = resultDic[@"list"];
        
        if (listArr == nil || [listArr isKindOfClass:[NSNull class]]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            return;
        }

        for (NSDictionary *dic in listArr) {
            PS_UserModel *user = [[PS_UserModel alloc] init];
            [user setValuesForKeysWithDictionary:dic];
            [_userListArr addObject:user];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tableView reloadData];
    } errorBlock:^(NSError *errorR) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)requestLikeUserList
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetMediaLikeListUrl];
    NSDictionary *params = @{@"appId":@(kPSAppid),
                             @"uid":_uid,
                             @"mediaId":_mediaID,
                             @"count":@10};
    [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"8888%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSArray *listArr = resultDic[@"list"];
        
        if (listArr == nil || [listArr isKindOfClass:[NSNull class]]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            return;
        }

        for (NSDictionary *dic in listArr) {
            PS_UserModel *user = [[PS_UserModel alloc] init];
            [user setValuesForKeysWithDictionary:dic];
            [_userListArr addObject:user];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tableView reloadData];
    } errorBlock:^(NSError *errorR) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _userListArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userList"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userList"];
    }
    
    PS_UserModel *model = _userListArr[indexPath.row];
    cell.textLabel.text = model.username;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:@"a"]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
