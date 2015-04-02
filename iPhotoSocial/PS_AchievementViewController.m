//
//  PS_AchievementViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_AchievementViewController.h"
#import "PS_ImageCollectionViewCell.h"
#import "PS_ImageDetailViewController.h"
#import "PS_SettingViewController.h"
#import "PS_UserListTableViewController.h"
#import "PS_DataRequest.h"
#import "MJRefresh.h"

#define kTopViewHeight 100

@interface PS_AchievementViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collect;
@property (nonatomic, strong) NSMutableArray *mediasArray;

@end

@implementation PS_AchievementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initSubViews];
    
    [self addHeaderRefresh];
    [self addfooterRefresh];
    
    if (_uid != nil) {
        [self requestLikeAndFollowCount];
        [self requestMediasListWithUid:0];
    }
}

- (void)initSubViews
{
    if ([_uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]) {
        self.navigationItem.title = @"username";
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"follow" style:UIBarButtonItemStylePlain target:self action:@selector(followButtonOnClick:)];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        
    }else{
        
        self.navigationItem.title = @"achievements";
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"share" style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonOnClick:)];
        self.navigationItem.leftBarButtonItem = leftButtonItem;
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"setting" style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonOnClick:)];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, kTopViewHeight)];
    view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [view addGestureRecognizer:tap];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    _collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kTopViewHeight + 64, kWindowWidth, kWindowHeight - kTopViewHeight - 64 - 49) collectionViewLayout:layout];
    _collect.dataSource = self;
    _collect.delegate = self;
    [self.view addSubview:_collect];
    
    [_collect registerClass:[PS_ImageCollectionViewCell class] forCellWithReuseIdentifier:@"Achievement"];
}

- (void)requestLikeAndFollowCount
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetUserLikeFollowUrl];
    NSDictionary *params = @{@"app_id":@kPSAppid,@"uid":_uid};
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"count    %@",result);
    }];
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    PS_UserListTableViewController *userListVC = [[PS_UserListTableViewController alloc] initWithStyle:UITableViewStylePlain];
    userListVC.uid = _uid;
    [self.navigationController pushViewController:userListVC animated:YES];
}

- (void)addHeaderRefresh
{
    __weak PS_AchievementViewController *weakSelf = self;
    [_collect addLegendHeaderWithRefreshingBlock:^{
        NSLog(@"header");
        [weakSelf.mediasArray removeAllObjects];
        [weakSelf requestMediasListWithUid:0];
    }];
    _collect.header.updatedTimeHidden = YES;
    _collect.header.stateHidden = YES;
}

- (void)addfooterRefresh
{
    __weak PS_AchievementViewController *weakSelf = self;
    [_collect addLegendFooterWithRefreshingBlock:^{
        NSLog(@"footer");
        [weakSelf requestMediasListWithUid:0];
    }];
    _collect.footer.stateHidden = YES;
    [_collect.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
}

#pragma mark -- 数据请求 --
- (void)requestMediasListWithUid:(NSInteger *)uid
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetExplorListUrl];
    NSDictionary *params = @{@"app_id":@kPSAppid,@"uid":@1};
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        [_collect.header endRefreshing];
        [_collect.footer endRefreshing];
    }];
}

- (void)shareButtonOnClick:(UIBarButtonItem *)barButton
{
    
}

- (void)settingButtonOnClick:(UIBarButtonItem *)barButton
{
    PS_SettingViewController *settingVC = [[PS_SettingViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)followButtonOnClick:(UIBarButtonItem *)barButoton
{
    
}

#pragma mark -- UICollectionViewDataSource UICollectionViewDelegate --
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 50;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Achievement" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"a"];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    PS_ImageDetailViewController *deteilVC = [[PS_ImageDetailViewController alloc] init];
    [self.navigationController pushViewController:deteilVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
