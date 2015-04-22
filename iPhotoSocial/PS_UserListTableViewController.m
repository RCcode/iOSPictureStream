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
#import "PS_UserViewCell.h"

@interface PS_UserListTableViewController ()

@property (nonatomic, strong) NSMutableArray *userListArr;

@end

@implementation PS_UserListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userListArr = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSLog(@"_uid = %@",_uid);
    if (_type == UserListTypeFollow) {
        self.title = LocalizedString(@"ps_user_followers", nil);
        [self requestFollowUserList];
    }else{
        self.title = LocalizedString(@"ps_fea_likes", nil);
        [self requestLikeUserList];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PS_UserViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"user"];
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if (listArr == nil || [listArr isKindOfClass:[NSNull class]]) {
            [PS_DataUtil showPromptWithText:LocalizedString(@"ps_load_failed", nil)];
            return;
        }

        for (NSDictionary *dic in listArr) {
            PS_UserModel *user = [[PS_UserModel alloc] init];
            [user setValuesForKeysWithDictionary:dic];
            [_userListArr addObject:user];
        }
        [self.tableView reloadData];
    } errorBlock:^(NSError *errorR) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [PS_DataUtil showPromptWithText:LocalizedString(@"ps_load_failed", nil)];
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (listArr == nil || [listArr isKindOfClass:[NSNull class]]) {
            [PS_DataUtil showPromptWithText:LocalizedString(@"ps_load_failed", nil)];
            return;
        }

        for (NSDictionary *dic in listArr) {
            PS_UserModel *user = [[PS_UserModel alloc] init];
            [user setValuesForKeysWithDictionary:dic];
            [_userListArr addObject:user];
        }
        [self.tableView reloadData];
    } errorBlock:^(NSError *errorR) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [PS_DataUtil showPromptWithText:LocalizedString(@"ps_load_failed", nil)];
    }];
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _userListArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PS_UserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user" forIndexPath:indexPath];
    
    PS_UserModel *model = _userListArr[indexPath.row];
    cell.userNameLabel.text = model.username;
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:@"mr_head"]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
