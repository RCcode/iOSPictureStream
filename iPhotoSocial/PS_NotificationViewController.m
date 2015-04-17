//
//  PS_NotificationViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_NotificationViewController.h"
#import "PS_NotificationModel.h"
#import "RC_moreAPPsLib.h"

@interface PS_NotificationViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *notisArray;

@end

@implementation PS_NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _notisArray = [[NSMutableArray alloc] initWithCapacity:1];
    [self initSubViews];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin]) {
        [self requestNotisficationList];
    }
}

- (void)initSubViews
{
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more"] style:UIBarButtonItemStylePlain target:self action:@selector(moreAppButtonOnClick:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list_choice"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteAll:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notifications"]];
    self.navigationItem.titleView = imageView;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)moreAppButtonOnClick:(UIBarButtonItem *)barButotn
{
    UIViewController *moreVC = [[RC_moreAPPsLib shareAdManager] getMoreAppController];
    moreVC.title = @"more app";
    moreVC.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonOnClick:)];
    moreVC.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UINavigationController *moreNC = [[UINavigationController alloc] initWithRootViewController:moreVC];
    [self presentViewController:moreNC animated:YES completion:nil];
}

- (void)closeButtonOnClick:(UIBarButtonItem *)barButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestNotisficationList
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
    return 80;
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
