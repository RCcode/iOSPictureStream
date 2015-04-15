//
//  PS_NotificationViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_NotificationViewController.h"
#import "MJRefresh.h"
#import "PS_NotificationModel.h"

@interface PS_NotificationViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *notisArray;

@end

@implementation PS_NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initSubViews];
    _notisArray = [[NSMutableArray alloc] initWithCapacity:1];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin]) {
        [self requestNotisficationListWithMinID:0];
        [self addHeaderRefresh];
        [self addfooterRefresh];
    }
}

- (void)initSubViews
{
    UIBarButtonItem *barButon = [[UIBarButtonItem alloc] initWithTitle:@"delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAll:)];
    self.navigationItem.rightBarButtonItem = barButon;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)addHeaderRefresh
{
    __weak PS_NotificationViewController *weakSelf = self;
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        NSLog(@"header");
        [weakSelf.notisArray removeAllObjects];
        [weakSelf requestNotisficationListWithMinID:0];
    }];
    _tableView.header.updatedTimeHidden = YES;
    _tableView.header.stateHidden = YES;
}

- (void)addfooterRefresh
{
    __weak PS_NotificationViewController *weakSelf = self;
    [_tableView addLegendFooterWithRefreshingBlock:^{
        NSLog(@"footer");
        [weakSelf requestNotisficationListWithMinID:0];
    }];
    _tableView.footer.stateHidden = YES;
    [_tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
}

- (void)requestNotisficationListWithMinID:(NSInteger)minID
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetNoticeUrl];
    NSDictionary *params = @{@"appId":@(kPSAppid),
                             @"uid":[[NSUserDefaults standardUserDefaults] objectForKey:kUid],
                             @"type":@1};
    [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"888888%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSArray *listArray = resultDic[@"list"];
        if (listArray == nil || [listArray isKindOfClass:[NSNull class]]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            return;
        }
        
        for (NSDictionary *dic in listArray) {
            PS_NotificationModel *model = [[PS_NotificationModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            [_notisArray addObject:model];
        }
        
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_tableView reloadData];
        
    } errorBlock:^(NSError *errorR) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark -- UITableViewDelegate  UITableViewDataSource--
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _notisArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notification"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notification"];
    }
    
    PS_NotificationModel *model = _notisArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",model.type];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = self.notisArray[indexPath.row];
    [self.notisArray removeObject:str];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)deleteAll:(UIBarButtonItem *)barButton
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:@"clear all" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.notisArray removeAllObjects];
        [_tableView reloadData];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:clearAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
