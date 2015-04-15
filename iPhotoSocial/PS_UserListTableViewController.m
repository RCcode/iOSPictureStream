//
//  PS_UserListTableViewController.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-2.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_UserListTableViewController.h"
#import "PS_UserModel.h"
#import "MJRefresh.h"

@interface PS_UserListTableViewController ()

@property (nonatomic, strong) NSMutableArray *userListArr;

@end

@implementation PS_UserListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self addHeaderRefresh];
//    [self addfooterRefresh];
    
    _userListArr = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSLog(@"_uid = %@",_uid);
    if (_type == UserListTypeFollow) {
        [self requestFollowUserList];
    }else{
        [self requestLikeUserList];
    }
}

//- (void)addHeaderRefresh
//{
//    __weak PS_UserListTableViewController *weakSelf = self;
//    [self.tableView  addLegendHeaderWithRefreshingBlock:^{
//        NSLog(@"header");
//        [weakSelf.userListArr removeAllObjects];
//        [weakSelf requestFollowUserListWithMinID:0];
//    }];
//    self.tableView .header.updatedTimeHidden = YES;
//    self.tableView .header.stateHidden = YES;
//}
//
//- (void)addfooterRefresh
//{
//    __weak PS_UserListTableViewController *weakSelf = self;
//    [self.tableView addLegendFooterWithRefreshingBlock:^{
//        NSLog(@"footer");
//        [weakSelf requestFollowUserListWithMinID:[weakSelf selectMinID]];
//    }];
//    self.tableView .footer.stateHidden = YES;
//    [self.tableView .footer setTitle:@"" forState:MJRefreshFooterStateIdle];
//}

- (void)requestFollowUserList
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetFollowListUrl];
    NSDictionary *params = @{@"appId":@(kPSAppid),
                             @"uid":_uid,
                             @"classify":@1};
    [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"7777777%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSArray *listArr = resultDic[@"list"];
        for (NSDictionary *dic in listArr) {
            PS_UserModel *user = [[PS_UserModel alloc] init];
            [user setValuesForKeysWithDictionary:dic];
            [_userListArr addObject:user];
        }
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)requestLikeUserList
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetFollowListUrl];
    NSDictionary *params = @{@"appId":@(kPSAppid),
                             @"uid":_uid,
                             @"mediaId":_mediaID};
    [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"8888%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSArray *listArr = resultDic[@"list"];
        for (NSDictionary *dic in listArr) {
            PS_UserModel *user = [[PS_UserModel alloc] init];
            [user setValuesForKeysWithDictionary:dic];
            [_userListArr addObject:user];
        }
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        NSLog(@"7777777%@",result);
    } errorBlock:^(NSError *errorR) {
        
    }];
}

////用最小ID用于分页
//- (NSInteger)selectMinID
//{
//    NSInteger min = NSIntegerMax;
//    for (PS_UserModel *model in _userListArr) {
//        if (min > model.compareID) {
//            min = model.compareID;
//        }
//    }
//    return min;
//}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
    
    cell.textLabel.text = @"ss";
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
