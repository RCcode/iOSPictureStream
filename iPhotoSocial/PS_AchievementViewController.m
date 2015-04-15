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
#import "PS_UserinfoView.h"
#import "PS_LoginViewController.h"
#import "UIImageEffects.h"
#import "RC_moreAPPsLib.h"

#define kTopViewHeight 179

@interface PS_AchievementViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UserInfoViewDelegate>

@property (nonatomic, strong) UICollectionView *collect;
@property (nonatomic, strong) UILabel *loginLabel;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) PS_UserinfoView *userInfoView;
@property (nonatomic, strong) NSMutableArray *mediasArray;

@property (nonatomic, strong) NSString *maxID; //用于分页
@property (nonatomic, assign) BOOL noMore;

@property (nonatomic ,strong) AFHTTPRequestOperationManager *manager;

@end

@implementation PS_AchievementViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin] && _collect == nil) {
        [_loginLabel removeFromSuperview];
        [_loginBtn removeFromSuperview];
        [self initSubViews];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self requestLikeAndFollowCount];
        [self requestMediasListWithMaxID:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = colorWithHexString(@"#f0f0f0");
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more"] style:UIBarButtonItemStylePlain target:self action:@selector(moreAppButtonOnClick:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_shezhi"] style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonOnClick:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    _loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120 + 64, kWindowWidth - 40, 0)];
    _loginLabel.text = @"Login with Instragram account to gain more likes and folllows from the No Croppers all over the world";
    _loginLabel.numberOfLines = 0;
    _loginLabel.textAlignment = NSTextAlignmentCenter;
    _loginLabel.font = [UIFont systemFontOfSize:17.0];
    _loginLabel.textColor = colorWithHexString(@"#989898");
    _loginLabel.backgroundColor = [UIColor whiteColor];
    [_loginLabel sizeToFit];
    [self.view addSubview:_loginLabel];

    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake((kWindowWidth - 176)/2, CGRectGetMaxY(_loginLabel.frame) + 32, 176, 37);
    [_loginBtn setImage:[UIImage imageNamed:@"profile_login"] forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
    _mediasArray = [[NSMutableArray alloc] initWithCapacity:1];

}

- (void)initSubViews
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 93, 28)];
    label.text = _userName;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Raleway-Thin" size:22.0];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    if (![_uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]) {
        //其他用户
        self.navigationItem.rightBarButtonItem = nil;
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
        self.navigationItem.leftBarButtonItem = leftButtonItem;
    }
    
    _userInfoView = [[[NSBundle mainBundle] loadNibNamed:@"PS_UserinfoView" owner:nil options:nil] firstObject];
    _userInfoView.frame = CGRectMake(0, 64, kWindowWidth, kTopViewHeight);
    _userInfoView.delegate = self;
    _userInfoView.usernameLabel.text = _userName;
    if ([_uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]) {
        _userInfoView.followBtn.hidden = YES;
    }
    _userInfoView.userImage.layer.cornerRadius = 69/2.0;
    _userInfoView.userImage.layer.masksToBounds = YES;
    [_userInfoView.userImage sd_setImageWithURL:[NSURL URLWithString:_userImage] placeholderImage:[UIImage imageNamed:@"a"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            _userInfoView.userBlurImage.image = [UIImageEffects blurImage:image gaussBlur:0.6];
            _userInfoView.userBlurImage.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                _userInfoView.userBlurImage.alpha = 1;
            }];
        }
    }];
    [self.view addSubview:_userInfoView];
        
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 2.5;
    layout.minimumLineSpacing = 2.5;
    CGFloat itemWidth = (kWindowWidth - 5)/3;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);    _collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kTopViewHeight + 64, kWindowWidth, kWindowHeight - kTopViewHeight - 64 - 49) collectionViewLayout:layout];
    _collect.backgroundColor = colorWithHexString(@"f4f4f4");
    _collect.dataSource = self;
    _collect.delegate = self;
    [self.view addSubview:_collect];
    
    [_collect registerClass:[PS_ImageCollectionViewCell class] forCellWithReuseIdentifier:@"Achievement"];
    [self addHeaderRefresh];
    [self addfooterRefresh];
}

- (void)requestLikeAndFollowCount
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetUserLikeFollowUrl];
    NSLog(@"_uid ==== %@",_uid);
    NSDictionary *params = @{@"appId":@kPSAppid,@"uid":_uid};
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"count    %@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        _userInfoView.likesCountLabel.text = [NSString stringWithFormat:@"%@",resultDic[@"likes"]];
        _userInfoView.followsCountLabel.text = [NSString stringWithFormat:@"%@",resultDic[@"follows"]];
    } errorBlock:^(NSError *errorR) {
        
    }];
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
    } errorBlock:^(NSError *errorR) {
        
    }];
}

- (void)backBtnClick:(UIBarButtonItem *)barButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreAppButtonOnClick:(UIBarButtonItem *)barButton
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

- (void)settingButtonOnClick:(UIBarButtonItem *)barButton
{
    PS_SettingViewController *settingVC = [[PS_SettingViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark -- UserInfoViewDelegate --
- (void)followBtnClick:(UIButton *)btn
{
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin];
    if (!isLogin) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"not login" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self login:nil];
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateFollowUrl];
        NSDictionary *params = @{@"appId":@kPSAppid,
                                 @"uid":[userDefaults objectForKey:kUid],
                                 @"userName":[userDefaults objectForKey:kUsername],
                                 @"pic":[userDefaults objectForKey:kPic],
                                 @"followUid":_uid};
        [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
            NSLog(@"follow%@",result);
        } errorBlock:^(NSError *errorR) {
            
        }];
    }
}

- (void)likesClick
{
//    PS_UserListTableViewController *userListVC = [[PS_UserListTableViewController alloc] init];
//    userListVC.uid = _uid;
//    [self.navigationController pushViewController:userListVC animated:YES];
}

- (void)followsClick
{
    PS_UserListTableViewController *userListVC = [[PS_UserListTableViewController alloc] init];
    userListVC.uid = _uid;
    userListVC.type = UserListTypeFollow;
    [self.navigationController pushViewController:userListVC animated:YES];
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

    cell.instragramModel = _mediasArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    PS_InstragramModel *model = _mediasArray[indexPath.row];
    if ([model.tags containsObject:@"rcnocrop"]) {
        PS_ImageDetailViewController *deteilVC = [[PS_ImageDetailViewController alloc] init];
        deteilVC.instragramModel = model;
        [self.navigationController pushViewController:deteilVC animated:YES];
    }else{
        PS_SignalImageViewController *signalVC = [[PS_SignalImageViewController alloc] init];
        signalVC.model = model;
        [self.navigationController pushViewController:signalVC animated:YES];
    }
}

#pragma mark -- login --
- (void)login:(UIButton *)button
{
    PS_LoginViewController *loginVC = [[PS_LoginViewController alloc] init];
    loginVC.loginSuccessBlock = ^(NSString *codeStr){
        _loginLabel.hidden = YES;
        _loginBtn.hidden = YES;
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
                    [self initSubViews];
                    [self requestLikeAndFollowCount];
                    [self requestMediasListWithMaxID:nil];
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
