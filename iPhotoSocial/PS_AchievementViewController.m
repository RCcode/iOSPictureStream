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
#import "PS_LoginViewController.h"
#import "UIImageEffects.h"
#import "RC_moreAPPsLib.h"
#import "PS_UserInfoReusableView.h"

#define kTopViewHeight 154

@interface PS_AchievementViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UserInfoViewDelegate>

@property (nonatomic, strong) UICollectionView *collect;
@property (nonatomic, strong) UILabel *loginLabel;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) PS_UserInfoReusableView *userInfoView;
@property (nonatomic, strong) NSMutableArray *mediasArray;

@property (nonatomic, strong) NSString *maxID; //用于分页
@property (nonatomic, assign) BOOL noMore;

@property (nonatomic ,strong) AFHTTPRequestOperationManager *manager;

@end

@implementation PS_AchievementViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin]) {
        if (_collect == nil) {
            _loginLabel.hidden = YES;
            _loginBtn.hidden = YES;
            [self initSubViews];
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self requestLikeAndFollowCount];
            [self requestMediasListWithMaxID:nil];
        }
    }else{
        self.navigationItem.titleView = nil;
        [_collect removeFromSuperview];
        _loginLabel.hidden = NO;
        _loginBtn.hidden = NO;
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
    _loginLabel.text = LocalizedString(@"ps_fea_login_text", nil);
    _loginLabel.numberOfLines = 0;
    _loginLabel.textAlignment = NSTextAlignmentCenter;
    _loginLabel.font = [UIFont systemFontOfSize:17.0];
    _loginLabel.textColor = colorWithHexString(@"#989898");
    _loginLabel.backgroundColor = [UIColor clearColor];
    [_loginLabel sizeToFit];
    CGPoint point = _loginLabel.center;
    _loginLabel.center = CGPointMake(kWindowWidth/2, point.y);
    [self.view addSubview:_loginLabel];

    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake((kWindowWidth - 213)/2, CGRectGetMaxY(_loginLabel.frame) + 32, 213, 34);
    [_loginBtn setTitle:LocalizedString(@"ps_exp_login_title", nil) forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"but_login"] forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
    _mediasArray = [[NSMutableArray alloc] initWithCapacity:1];
}

- (void)initSubViews
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    label.text = _userName;
    label.textColor = [UIColor whiteColor];
//    label.font = [UIFont systemFontOfSize:22.0];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"en"]) {
        label.font = [UIFont fontWithName:@"Maven Pro Light" size:24.0];
    }else{
        label.font = [UIFont systemFontOfSize:20.0];
    }

    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    if (![_uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]) {
        //其他用户
        self.navigationItem.rightBarButtonItem = nil;
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
        self.navigationItem.leftBarButtonItem = leftButtonItem;
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 2.5;
    layout.minimumLineSpacing = 2.5;
    CGFloat itemWidth = (kWindowWidth - 5)/3;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    _collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, kWindowHeight - 64 - 49) collectionViewLayout:layout];
    _collect.backgroundColor = colorWithHexString(@"f4f4f4");
    _collect.dataSource = self;
    _collect.delegate = self;
    [self.view addSubview:_collect];
    
    [_collect registerClass:[PS_ImageCollectionViewCell class] forCellWithReuseIdentifier:@"Achievement"];
    [_collect registerNib:[UINib nibWithNibName:@"PS_UserInfoReusableView" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    
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
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *resultDic = (NSDictionary *)result;
        _userInfoView.likesCountLabel.text = [NSString stringWithFormat:@"%@",resultDic[@"likes"]];
        _userInfoView.followsCountLabel.text = [NSString stringWithFormat:@"%@",resultDic[@"follows"]];
    } errorBlock:^(NSError *errorR) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)addHeaderRefresh
{
    __weak PS_AchievementViewController *weakSelf = self;
    [_collect addLegendHeaderWithRefreshingBlock:^{
        NSLog(@"header");
        weakSelf.noMore = NO;
        [weakSelf requestUserInfo];
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
            [PS_DataUtil showPromptWithText:LocalizedString(@"ps_exp_no_more_photo", nil)];
            return;
        }
        [weakSelf requestMediasListWithMaxID:weakSelf.maxID];
    }];
    _collect.footer.stateHidden = YES;
    [_collect.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
}

#pragma mark -- 数据请求 --
//请求用户信息展示在头部
- (void)requestUserInfo
{
    NSString *userUrl= [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/",_uid];
    NSDictionary *userParams = @{@"access_token":[[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken]};
    [PS_DataRequest requestWithURL:userUrl params:[userParams mutableCopy] httpMethod:@"GET" block:^(NSObject *result) {
        NSLog(@"userinfo%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSDictionary *dataDic = resultDic[@"data"];
        
        //更新到服务器
        NSString *registUrl = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSRegistUserInfoUrl];
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSDictionary *registparams = @{@"uid":dataDic[@"id"],
                                       @"appId":@(kPSAppid),
                                       @"token":[[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken],
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
        } errorBlock:^(NSError *errorR) {
            NSLog(@"注册用户信息失败");
        }];
        
    } errorBlock:^(NSError *errorR) {
        NSLog(@"获取用户信息失败");
    }];
}

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
        
        [_collect.header endRefreshing];
        [_collect.footer endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if ([resultDic[@"pagination"] allKeys].count == 0) {
            _noMore = YES;
        }else{
            self.maxID = resultDic[@"pagination"][@"next_max_id"];
        }
        
        if (maxID == nil) {
            [_mediasArray removeAllObjects];
        }
        
        for (NSDictionary *dic in dataArray) {
            PS_InstragramModel *model = [[PS_InstragramModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            [_mediasArray addObject:model];
        }
        
        [_collect reloadData];
        
        //插入用户带标签的图片到自己服务器
        [self insertMediasIntoServer];
    } errorBlock:^(NSError *errorR) {
        [_collect.header endRefreshing];
        [_collect.footer endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [PS_DataUtil showPromptWithText:LocalizedString(@"ps_load_failed", nil)];
    }];
}

- (void)insertMediasIntoServer
{
    NSMutableArray *modelArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (PS_InstragramModel *model in _mediasArray) {
        if ([model.tags containsObject:@"rcnocrop"]) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        model.media_id,@"mediaId",
                                        [model.type isEqualToString:@"image"]?@0:@1,@"mediaType",
                                        model.images[@"standard_resolution"][@"url"],@"mediaPic",
                                        model.desc,@"mediaDesc",
                                        model.likes,@"likes",
                                        @"rcnocrop",@"tag", nil];
            if ([model.type isEqualToString:@"video"]) {
                [dic setValue:model.videos[@"standard_resolution"][@"url"] forKey:@"mediaUrl"];
            }
            [modelArray addObject:dic];
        }
    }
    if (modelArray.count > 0) {
        NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSInsertMediasUrl];
        NSDictionary *params = @{@"appId":@(kPSAppid),
                                 @"uid":_uid,
                                 @"userName":_userName,
                                 @"pic":_userImage,
                                 @"list":modelArray};
        [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
            NSLog(@"insert  result%@",result);
        } errorBlock:^(NSError *errorR) {
            NSLog(@"插入失败");
        }];
    }
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
- (void)followBtnClick:(UIButton *)button
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //更改界面
    button.enabled = NO;
    
    //Instragram
    NSString *followUrl = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/relationship",_uid];
    NSDictionary *followParams = @{@"access_token":[userDefaults objectForKey:kAccessToken],
                                   @"action":@"follow"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:followUrl parameters:[followParams mutableCopy] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        
        if ([responseObject[@"meta"][@"code"] integerValue] == 200) {
            //自己服务器
            NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateFollowUrl];
            NSDictionary *params = @{@"appId":@kPSAppid,
                                     @"uid":[userDefaults objectForKey:kUid],
                                     @"userName":[userDefaults objectForKey:kUsername],
                                     @"pic":[userDefaults objectForKey:kPic],
                                     @"followUid":_uid};
            [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
                NSLog(@"follow%@",result);
                NSDictionary *resultDic = (NSDictionary *)result;
                if ([resultDic[@"stat"] integerValue] == 10000) {
                    //成功
                }else{
                    
                }
            } errorBlock:^(NSError *errorR) {
                
            }];
        }else{
            button.enabled = YES;
            [PS_DataUtil showPromptWithText:LocalizedString(@"ps_operation_failed", nil)];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        button.enabled = YES;
        [PS_DataUtil showPromptWithText:LocalizedString(@"ps_operation_failed", nil)];
    }];
}

- (void)likesClick
{
}

- (void)followsClick
{
    PS_UserListTableViewController *userListVC = [[PS_UserListTableViewController alloc] init];
    userListVC.uid = _uid;
    userListVC.type = UserListTypeFollow;
    [self.navigationController pushViewController:userListVC animated:YES];
}

#pragma mark -- UICollectionViewDataSource UICollectionViewDelegate --
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _mediasArray.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kWindowWidth, kTopViewHeight);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        _userInfoView = (PS_UserInfoReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        _userInfoView.delegate = self;
        _userInfoView.usernameLabel.text = _userName;
        if ([_uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]) {
            _userInfoView.followBtn.hidden = YES;
        }
        
        [_userInfoView.userImage sd_setImageWithURL:[NSURL URLWithString:_userImage] placeholderImage:[UIImage imageNamed:@"mr_head"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                _userInfoView.userBlurImage.image = [UIImageEffects blurImage:image gaussBlur:0.6];
//                _userInfoView.userBlurImage.alpha = 0;
//                [UIView animateWithDuration:0.5 animations:^{
//                    _userInfoView.userBlurImage.alpha = 1;
//                }];
            }
        }];
        return _userInfoView;
    }
    return nil;
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
        [_manager.requestSerializer setValue:getHeaderData() forHTTPHeaderField:@"X-Insta-Forwarded-For"];
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
                    
                    //记录用户信息
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:dataDic[@"id"] forKey:kUid];
                    [userDefaults setObject:dataDic[@"username"] forKey:kUsername];
                    [userDefaults setObject:dataDic[@"profile_picture"] forKey:kPic];
                    [userDefaults setObject:resultDic[@"access_token"] forKey:kAccessToken];
                    [userDefaults setBool:YES forKey:kIsLogin];
                    [userDefaults synchronize];
                    
                    //需要传给个人页uid
                    _uid = dataDic[@"id"];
                    _userName = dataDic[@"username"];
                    _userImage = dataDic[@"profile_picture"];
                    
                    [self initSubViews];
                    [self requestLikeAndFollowCount];
                    [self requestMediasListWithMaxID:nil];
                } errorBlock:^(NSError *errorR) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }];
            } errorBlock:^(NSError *errorR) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error = %@",error.description);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
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
