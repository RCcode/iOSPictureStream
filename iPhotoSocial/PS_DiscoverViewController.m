//
//  PS_findViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_DiscoverViewController.h"
#import "PS_ImageCollectionViewCell.h"
#import "PS_ImageDetailViewController.h"
#import "PS_AchievementViewController.h"
#import "PS_LoginViewController.h"
#import "RC_moreAPPsLib.h"
#import "PS_MediaModel.h"
#import "MJRefresh.h"
#import "PS_DataUtil.h"
#import "AFNetworking.h"
#import "PS_LoginView.h"

#define kLoginViewHeight 50

@interface PS_DiscoverViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,LoginViewDelegate>

@property (nonatomic, strong) PS_LoginView *loginView;
@property (nonatomic, strong) UICollectionView *collect;
@property (nonatomic, strong) NSMutableArray * mediasArray;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end

@implementation PS_DiscoverViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin]) {
        _loginView.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initSubViews];
    
    _mediasArray = [[NSMutableArray alloc] initWithCapacity:1];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self requestMediasListWithTeams:nil];
}

- (void)initSubViews
{
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more"] style:UIBarButtonItemStylePlain target:self action:@selector(moreAppButtonOnClick:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_nocrop"]];
    self.navigationItem.titleView = imageView;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 2.5;
    layout.minimumLineSpacing = 2.5;
    CGFloat itemWidth = (kWindowWidth - 5)/3;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    _collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) collectionViewLayout:layout];
    _collect.backgroundColor = colorWithHexString(@"f4f4f4");
    _collect.dataSource = self;
    _collect.delegate = self;
    [self.view addSubview:_collect];
    [_collect registerClass:[PS_ImageCollectionViewCell class] forCellWithReuseIdentifier:@"discover"];
    
    [self addHeaderRefresh];
    [self addfooterRefresh];
    
    _loginView = [[PS_LoginView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, 44)];
    _loginView.delegate = self;
    [self.view addSubview:_loginView];
}

- (void)addHeaderRefresh
{
    __weak PS_DiscoverViewController *weakSelf = self;
    [_collect addLegendHeaderWithRefreshingBlock:^{
        NSLog(@"header");
        [weakSelf.mediasArray removeAllObjects];
        [weakSelf requestMediasListWithTeams:nil];
    }];
    _collect.header.updatedTimeHidden = YES;
    _collect.header.stateHidden = YES;
}

- (void)addfooterRefresh
{
    __weak PS_DiscoverViewController *weakSelf = self;
    [_collect addLegendFooterWithRefreshingBlock:^{
        NSLog(@"footer");
        [weakSelf requestMediasListWithTeams:[PS_DataUtil defaultDateUtil].c_teamArray];
    }];
    _collect.footer.stateHidden = YES;
    [_collect.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
}

#pragma mark -- 数据请求 --
- (void)requestMediasListWithTeams:(NSMutableArray *)c_team
{
    NSDictionary *params = nil;
    if (c_team == nil) {
        params = @{@"appId":@kPSAppid,@"uid":@1};
    }else{
        params = @{@"appId":@kPSAppid,@"uid":@1,@"cteams":[PS_DataUtil defaultDateUtil].c_teamArray};
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetExplorListUrl];
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        [PS_DataUtil defaultDateUtil].c_teamArray = resultDic[@"cteams"];
        NSArray *listArr = resultDic[@"list"];
        
        if (listArr.count == 0) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"没有更多了";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:1];
        }
        
        for (NSDictionary *dic in listArr) {
            PS_MediaModel *model = [[PS_MediaModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            [_mediasArray addObject:model];
        }
        
        [_collect.header endRefreshing];
        [_collect.footer endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_collect reloadData];
    } errorBlock:^(NSError *errorR) {
        
    }];
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

#pragma mark -- UICollectionViewDataSource UICollectionViewDelegate --

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _mediasArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discover" forIndexPath:indexPath];
    
    cell.model = _mediasArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    PS_ImageDetailViewController *deteilVC = [[PS_ImageDetailViewController alloc] init];
    deteilVC.model = _mediasArray[indexPath.row];
    [self.navigationController pushViewController:deteilVC animated:YES];
}

#pragma mark -- login --
- (void)login:(UIButton *)button
{
    PS_LoginViewController *loginVC = [[PS_LoginViewController alloc] init];
    loginVC.loginSuccessBlock = ^(NSString *codeStr){
        _loginView.hidden = YES;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //获取token
        NSString *url = @"https://api.instagram.com/oauth/access_token?scope=likes+relationships";
        NSDictionary *params = @{@"client_id":kClientId,
                                 @"client_secret":kClientSecret,
                                 @"grant_type":@"authorization_code",
                                 @"redirect_uri":kRedirectUri,
                                 @"code":codeStr};
        _manager = [AFHTTPRequestOperationManager manager];
        [_manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *resultDic = (NSDictionary*)responseObject;
            NSLog(@"%@",resultDic);
            //获取用户信息
            NSString *userurl= [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/",resultDic[@"user"][@"id"]];
            NSDictionary *userParams = @{@"access_token":resultDic[@"access_token"]};
            [PS_DataRequest requestWithURL:userurl params:[userParams mutableCopy] httpMethod:@"GET" block:^(NSObject *result) {
                NSLog(@"user info = %@",result);
                NSDictionary *userInfoDic = (NSDictionary *)result;
                NSDictionary *dataDic = userInfoDic[@"data"];
                
                //记录用户信息
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:dataDic[@"id"] forKey:kUid];
                [userDefaults setObject:dataDic[@"username"] forKey:kUsername];
                [userDefaults setObject:dataDic[@"profile_picture"] forKey:kPic];
                [userDefaults setObject:resultDic[@"access_token"] forKey:kAccessToken];
                [userDefaults setBool:YES forKey:kIsLogin];
                [userDefaults synchronize];
                
                //需要传给个人页uid
                UINavigationController *na = self.tabBarController.viewControllers[3];
                PS_AchievementViewController *achievement = na.viewControllers[0];
                achievement.uid = dataDic[@"id"];
                achievement.userName = dataDic[@"username"];
                achievement.userImage = dataDic[@"profile_picture"];
                
                //注册到服务器
                NSString *registUrl = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSRegistUserInfoUrl];
                NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
                NSDictionary *registparams = @{@"uid":dataDic[@"id"],
                                               @"appId":@(kPSAppid),
                                               @"token":resultDic[@"access_token"],
                                               @"userName":dataDic[@"username"],
                                               @"fullName":dataDic[@"full_name"],
                                               @"pic":dataDic[@"profile_picture"],
                                               @"bio":dataDic[@"bio"],
                                               @"website":dataDic[@"website"],
                                               @"media":dataDic[@"counts"][@"media"],
                                               @"follows":dataDic[@"counts"][@"follows"],
                                               @"followed":dataDic[@"counts"][@"followed_by"],
                                               @"language":language,
                                               @"plat":@0};
    
                [PS_DataRequest requestWithURL:registUrl params:[registparams mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
                    NSLog(@"qqqqqqqq%@",result);
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                } errorBlock:^(NSError *errorR) {
                    
                }];
            } errorBlock:^(NSError *errorR) {
                
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error = %@",error.description);
        }];
    };
    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:loginNC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
