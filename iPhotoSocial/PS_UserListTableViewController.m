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
    
    [self addHeaderRefresh];
    [self addfooterRefresh];
    
    _userListArr = [[NSMutableArray alloc] initWithCapacity:1];
    if (_uid != nil) {
        NSLog(@"%@",_uid);
        [self requestUserListWithMinID:0];
    }
}

- (void)addHeaderRefresh
{
    __weak PS_UserListTableViewController *weakSelf = self;
    [self.tableView  addLegendHeaderWithRefreshingBlock:^{
        NSLog(@"header");
        [weakSelf.userListArr removeAllObjects];
        [weakSelf requestUserListWithMinID:0];
    }];
    self.tableView .header.updatedTimeHidden = YES;
    self.tableView .header.stateHidden = YES;
}

- (void)addfooterRefresh
{
    __weak PS_UserListTableViewController *weakSelf = self;
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        NSLog(@"footer");
        [weakSelf requestUserListWithMinID:[weakSelf selectMinID]];
    }];
    self.tableView .footer.stateHidden = YES;
    [self.tableView .footer setTitle:@"" forState:MJRefreshFooterStateIdle];
}

- (void)requestUserListWithMinID:(NSInteger)minID
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetFollowListUrl];
    NSDictionary *params = @{@"appId":@(kPSAppid),
                             @"uid":_uid,
                             @"id":@(minID),
                             @"count":@10,
                             @"classify":@0};
    [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        NSLog(@"7777777%@",result);
    } errorBlock:^(NSError *errorR) {
        
    }];
}

//用最小ID用于分页
- (NSInteger)selectMinID
{
    NSInteger min = NSIntegerMax;
    for (PS_UserModel *model in _userListArr) {
        if (min > model.compareID) {
            min = model.compareID;
        }
    }
    return min;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
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
