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
#import "MJRefresh.h"
#import "PS_InstragramModel.h"
#import "UIImageView+WebCache.h"
#import "PS_SignalImageViewController.h"

#define kTopViewHeight 100

@interface PS_AchievementViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collect;
@property (nonatomic, strong) UILabel *loginLabel;
@property (nonatomic, strong) NSMutableArray *mediasArray;

@property (nonatomic, strong) NSString *likes;


@property (nonatomic, strong) NSString *maxID; //用于分页
@property (nonatomic, assign) BOOL noMore;

@end

@implementation PS_AchievementViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin] && _collect == nil) {
        [_loginLabel removeFromSuperview];
        [self initSubViews];
        
        [self addHeaderRefresh];
        [self addfooterRefresh];
        
        _mediasArray = [[NSMutableArray alloc] initWithCapacity:1];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self requestLikeAndFollowCount];
        [self requestMediasListWithMaxID:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    _loginLabel.text = @"to login";
    _loginLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_loginLabel];
}

- (void)initSubViews
{
    if ([_uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]) {
        //个人
        self.navigationItem.title = @"achievements";
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"share" style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonOnClick:)];
        self.navigationItem.leftBarButtonItem = leftButtonItem;
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"setting" style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonOnClick:)];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }else{
        //其他用户
        self.navigationItem.title = @"username";
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"follow" style:UIBarButtonItemStylePlain target:self action:@selector(followButtonOnClick:)];
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
    _collect.backgroundColor = [UIColor whiteColor];
    _collect.dataSource = self;
    _collect.delegate = self;
    [self.view addSubview:_collect];
    
    [_collect registerClass:[PS_ImageCollectionViewCell class] forCellWithReuseIdentifier:@"Achievement"];
}

- (void)requestLikeAndFollowCount
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetUserLikeFollowUrl];
    NSLog(@"_uid ==== %@",_uid);
    NSDictionary *params = @{@"appId":@kPSAppid,@"uid":_uid};
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"count    %@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        _likes = [NSString stringWithFormat:@"%@",resultDic[@"likes"]];
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
        weakSelf.noMore = NO;
        [weakSelf.mediasArray removeAllObjects];
        [weakSelf requestMediasListWithMaxID:nil];
    }];
    _collect.header.updatedTimeHidden = YES;
    _collect.header.stateHidden = YES;
}

- (void)addfooterRefresh
{
    __weak PS_AchievementViewController *weakSelf = self;
    [_collect addLegendFooterWithRefreshingBlock:^{
        NSLog(@"footer");
        if (weakSelf.noMore == YES) {
            [weakSelf.collect.footer endRefreshing];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            hud.labelText = @"没有更多了";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:1];
            return;
        }
        [weakSelf requestMediasListWithMaxID:weakSelf.maxID];
    }];
    _collect.footer.stateHidden = YES;
    [_collect.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
}

#pragma mark -- 数据请求 --
- (void)requestMediasListWithMaxID:(NSString *)maxID
{
    NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/",_uid];
    NSDictionary *params = nil;
    if (maxID == nil) {
        params = @{@"access_token":[[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken],
                   @"count":@24};
    }else{
        params = @{@"access_token":[[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken],
                   @"count":@24,
                   @"max_id":_maxID};
    }
    
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"GET" block:^(NSObject *result) {
        NSLog(@"list     %@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSArray *dataArray = resultDic[@"data"];
        
        NSLog(@"%@",resultDic[@"pagination"][@"next_max_id"]);
        if ([resultDic[@"pagination"] allKeys].count == 0) {
            _noMore = YES;
        }else{
            self.maxID = resultDic[@"pagination"][@"next_max_id"];
        }
        
        for (NSDictionary *dic in dataArray) {
            PS_InstragramModel *model = [[PS_InstragramModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            [_mediasArray addObject:model];
        }
        [_collect.header endRefreshing];
        [_collect.footer endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_collect reloadData];
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
    return _mediasArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Achievement" forIndexPath:indexPath];
    
    PS_InstragramModel *model = _mediasArray[indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.images[@"thumbnail"][@"url"]] placeholderImage:[UIImage imageNamed:@"a"]];
    
    cell.tagLabel.hidden = YES;
    if ([model.tags containsObject:@"rcnocrop"]) {
        cell.tagLabel.text = @"nocrop";
        cell.tagLabel.hidden = NO;
    }
    
    if ([model.type isEqualToString:@"video"]) {
        cell.tagLabel.text = @"video";
        cell.tagLabel.hidden = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    PS_InstragramModel *model = _mediasArray[indexPath.row];
    if ([model.tags containsObject:@"rcnocrop"]) {
        PS_ImageDetailViewController *deteilVC = [[PS_ImageDetailViewController alloc] init];
        model.likes = _likes;
        deteilVC.instragramModel = model;
        [self.navigationController pushViewController:deteilVC animated:YES];
    }else{
        PS_SignalImageViewController *signalVC = [[PS_SignalImageViewController alloc] init];
        signalVC.model = model;
        [self.navigationController pushViewController:signalVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
