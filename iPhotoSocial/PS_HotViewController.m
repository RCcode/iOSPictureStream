//
//  PS_HotViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_HotViewController.h"
#import "PS_ImageDetailViewCell.h"
#import "PS_AchievementViewController.h"
#import "PS_LoginViewController.h"
#import "PS_MediaModel.h"
#import "MJRefresh.h"
#import "PS_UserListTableViewController.h"
#import "PS_RepostViewController.h"
#import "PS_LoginAlertView.h"
#import "PS_LoginView.h"

#define kLoginViewHeight 50

@interface PS_HotViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,LoginViewDelegate>

@property (nonatomic, strong) PS_LoginView *loginView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PS_LoginAlertView *loginAlert;
@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) NSMutableArray *mediasArray;

@end

@implementation PS_HotViewController

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
    [self addHeaderRefresh];
    [self addfooterRefresh];
    
    _mediasArray = [NSMutableArray arrayWithCapacity:1];
    [self requestMediasListWithMinID:0];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)initSubViews
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    label.text = LocalizedString(@"ps_fea_featured", nil);
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:22.0];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 460;
    _tableView.delaysContentTouches = NO;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"PS_ImageDetailViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"imageDetail"];
    
    _loginView = [[PS_LoginView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, 44) text:LocalizedString(@"ps_exp_login_text", nil)];
    _loginView.delegate = self;
    [self.view addSubview:_loginView];
}

- (void)addHeaderRefresh
{
    __weak PS_HotViewController *weakSelf = self;
    [_tableView addLegendHeaderWithRefreshingBlock:^{
//        [weakSelf.mediasArray removeAllObjects];
        [weakSelf requestMediasListWithMinID:0];
    }];
    _tableView.header.updatedTimeHidden = YES;
    _tableView.header.stateHidden = YES;
}

- (void)addfooterRefresh
{
    __weak PS_HotViewController *weakSelf = self;
    [_tableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf requestMediasListWithMinID:[weakSelf selectMinID]];
    }];
    _tableView.footer.stateHidden = YES;
    [_tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
}

#pragma mark -- 数据请求 --
- (void)requestMediasListWithMinID:(NSInteger)minID
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetRecommendMediaListUrl];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(kPSAppid),@"appId",@10,@"count", nil];

    if (minID != 0) {
        [params setValue:@(minID) forKey:@"id"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin]) {
        [params setValue:[[NSUserDefaults standardUserDefaults] objectForKey:kUid] forKey:@"uid"];
    }

    [PS_DataRequest requestWithURL:url params:params httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSArray *listArr = resultDic[@"list"];
        
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (listArr == nil || [listArr isKindOfClass:[NSNull class]]) {
            [PS_DataUtil showPromptWithText:LocalizedString(@"ps_load_failed", nil)];
            return;
        }

        if (listArr.count == 0) {
            [PS_DataUtil showPromptWithText:LocalizedString(@"ps_exp_no_more_photo", nil)];
        }
        
        if(minID == 0){
            [_mediasArray removeAllObjects];
        }
        
        for (NSDictionary *dic in listArr) {
            PS_MediaModel *model = [[PS_MediaModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            [_mediasArray addObject:model];
        }
        
        [_tableView reloadData];
        
    } errorBlock:^(NSError *errorR) {
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [PS_DataUtil showPromptWithText:LocalizedString(@"ps_load_failed", nil)];
    }];
}

//用最小ID用于分页
- (NSInteger)selectMinID
{
    NSInteger min = NSIntegerMax;
    for (PS_MediaModel *model in _mediasArray) {
        if (min > model.compare_id) {
            min = model.compare_id;
        }
    }
    return min;
}

#pragma mark -- UITableViewDelegate  UITableViewDataSource--
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_mediasArray.count == 0) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _mediasArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageDetail" forIndexPath:indexPath];
    
    PS_MediaModel *model = self.mediasArray[indexPath.row];
    cell.model = model;
    
    cell.userButton.tag = indexPath.row;
    [cell.userButton addTarget:self action:@selector(userBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    cell.followButton.tag = indexPath.row;
//    [cell.followButton addTarget:self action:@selector(followBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.followButton.hidden = YES;
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.likesListButton.tag = indexPath.row;
    [cell.likesListButton addTarget:self action:@selector(likesListBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.appButton.tag = indexPath.row;
    [cell.appButton addTarget:self action:@selector(appBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.repostButton.tag = indexPath.row;
    [cell.repostButton addTarget:self action:@selector(repostBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)userBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        PS_MediaModel *model = self.mediasArray[button.tag];
        PS_AchievementViewController *achieveVC = [[PS_AchievementViewController alloc] init];
        achieveVC.uid = model.uid;
        achieveVC.userName = model.userName;
        achieveVC.userImage = model.pic;
        [self.navigationController pushViewController:achieveVC animated:YES];
    }
}

//- (void)followBtnClick:(UIButton *)button
//{
//    if ([self showLoginAlertIfNotLogin]) {
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        PS_MediaModel *model = _mediasArray[button.tag];
//        
//        //更改界面
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
//        button.enabled = NO;
//        
//        //Instragram
//        NSString *followUrl = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/relationship",model.uid];
//        NSDictionary *followParams = @{@"access_token":[userDefaults objectForKey:kAccessToken],
//                                       @"action":@"follow"};
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        [manager POST:followUrl parameters:[followParams mutableCopy] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"%@",responseObject);
//            
//            if ([responseObject[@"meta"][@"code"] integerValue] == 200) {
//                //自己服务器
//                NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateFollowUrl];
//                NSDictionary *params = @{@"appId":@kPSAppid,
//                                         @"uid":[userDefaults objectForKey:kUid],
//                                         @"userName":[userDefaults objectForKey:kUsername],
//                                         @"pic":[userDefaults objectForKey:kPic],
//                                         @"followUid":model.uid};
//                [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
//                    NSLog(@"follow%@",result);
//                    NSDictionary *resultDic = (NSDictionary *)result;
//                    if ([resultDic[@"stat"] integerValue] == 10000) {
//                        model.isFollowed = YES;
//                    }else{
//                        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                    }
//                } errorBlock:^(NSError *errorR) {
//                    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                }];
//            }else{
//                [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        }];
//    }
//}

- (void)likeBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        PS_MediaModel *model = _mediasArray[button.tag];
        
        PS_ImageDetailViewCell *cell = (PS_ImageDetailViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
        cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld",cell.likeCountLabel.text.integerValue + 1];
        button.enabled = NO;
        
        //查询是否已经like过这个media
        NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@",model.mediaId];
        NSDictionary *params = @{@"access_token":[[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken]};
        [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"GET" block:^(NSObject *result) {
            NSLog(@"ssssddddddddd%@",result);
            NSDictionary *resultDic = (NSDictionary *)result;
            
            if ([resultDic[@"data"][@"user_has_liked"] boolValue]==0) {
                
                //Instragram先like
                NSString *likeUrl = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes",model.mediaId];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *likeParams = @{@"access_token":[userDefaults objectForKey:kAccessToken]};
                [manager POST:likeUrl parameters:likeParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"dddddddddd%@",responseObject);
                    if ([responseObject[@"meta"][@"code"] integerValue] == 200) {
                        //服务器加1
                        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateLikeUrl];
                        NSDictionary *params = @{@"appId":@kPSAppid,
                                                 @"uid":[userDefaults objectForKey:kUid],
                                                 @"userName":[userDefaults objectForKey:kUsername],
                                                 @"pic":[userDefaults objectForKey:kPic],
                                                 @"likeUid":model.uid,
                                                 @"mediaId":model.mediaId,
                                                 @"tag":model.tag};
                        [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
                            NSLog(@"like%@",result);
                            NSDictionary *resultDic = (NSDictionary *)result;
                            if ([resultDic[@"stat"] integerValue] == 10000) {
                                model.isLiked = YES;
                                model.likes = [NSString stringWithFormat:@"%ld",model.likes.integerValue + 1];
                            }else{
                                //服务器异常
                                // [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            }
                            
                        } errorBlock:^(NSError *errorR) {
                            //instragram成功 自己服务器没成功
                            //[PS_DataUtil showPromptWithText:LocalizedString(@"ps_operation_failed", nil)];
                            // [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }];
                        
                    }else{
                        //instragram code!=200
                        [PS_DataUtil showPromptWithText:LocalizedString(@"ps_operation_failed", nil)];
                        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [PS_DataUtil showPromptWithText:LocalizedString(@"ps_operation_failed", nil)];
                    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }];
                
            }else{
                //已经like过了
                cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld",cell.likeCountLabel.text.integerValue - 1];
            }
            
        } errorBlock:^(NSError *errorR) {
            [PS_DataUtil showPromptWithText:LocalizedString(@"ps_operation_failed", nil)];
        }];
    }
}

//- (void)likeBtnClick:(UIButton *)button
//{
//    if ([self showLoginAlertIfNotLogin]) {
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        PS_MediaModel *model = _mediasArray[button.tag];
//        //界面上先加1
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
//        PS_ImageDetailViewCell *cell = (PS_ImageDetailViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
//        cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld",cell.likeCountLabel.text.integerValue + 1];
//#warning 需要从instragram判断是否like过决定按钮开始是否可点
//        button.enabled = NO;
//
//        //Instragram先like
//        NSString *likeUrl = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes",model.mediaId];
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        NSDictionary *likeParams = @{@"access_token":[userDefaults objectForKey:kAccessToken]};
//        [manager POST:likeUrl parameters:likeParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"dddddddddd%@",responseObject);
//            if ([responseObject[@"meta"][@"code"] integerValue] == 200) {
//                //服务器加1
//                NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateLikeUrl];
//                NSDictionary *params = @{@"appId":@kPSAppid,
//                                         @"uid":[userDefaults objectForKey:kUid],
//                                         @"userName":[userDefaults objectForKey:kUsername],
//                                         @"pic":[userDefaults objectForKey:kPic],
//                                         @"likeUid":model.uid,
//                                         @"mediaId":model.mediaId,
//                                         @"tag":model.tag};
//                [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
//                    NSLog(@"like%@",result);
//                    
//                    NSDictionary *resultDic = (NSDictionary *)result;
//                    if ([resultDic[@"stat"] integerValue] == 10000) {
//                        model.isLiked = YES;
//                        model.likes = [NSString stringWithFormat:@"%ld",model.likes.integerValue + 1];
//                    }else{
//                        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                    }
//                } errorBlock:^(NSError *errorR) {
//                    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                }];
//            }else{
//                [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        }];
//    }
//}

- (void)likesListBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        PS_MediaModel *model = _mediasArray[button.tag];
        PS_UserListTableViewController *userListVC = [[PS_UserListTableViewController alloc] init];
        userListVC.uid = model.uid;
        userListVC.type = UserListTypeLike;
        userListVC.mediaID = model.mediaId;
        [self.navigationController pushViewController:userListVC animated:YES];
    }
}

- (void)repostBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        PS_RepostViewController *repostVC = [[PS_RepostViewController alloc] init];
        repostVC.mModel = _mediasArray[button.tag];
        repostVC.type = kComeFromServer;
        [repostVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:repostVC animated:YES];
    }
}

- (void)appBtnClick:(UIButton *)button
{
    PS_MediaModel *model = _mediasArray[button.tag];
    NSLog(@"aaaaa%@",model.downUrl);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.downUrl]];
}

- (BOOL)showLoginAlertIfNotLogin
{
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin];
    if (!isLogin) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight)];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self.view.window addSubview:_backView];
        
        _backView.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            _backView.alpha = 1;
        }];
        
        _loginAlert = [[[NSBundle mainBundle] loadNibNamed:@"PS_LoginAlertView" owner:nil options:nil] lastObject];
        _loginAlert.center  = self.view.center;
        [self.view.window addSubview:_loginAlert];
        
        _loginAlert.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            _loginAlert.alpha = 1;
        }];
        
        [_loginAlert.loginButton setTitle:LocalizedString(@"ps_exp_login_title", nil) forState:UIControlStateNormal];
        [_loginAlert.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        [_loginAlert.closeButton addTarget:self action:@selector(cancelLogin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return isLogin;
}

#pragma mark -- login --
- (void)login:(UIButton *)button
{
    [_loginAlert removeFromSuperview];
    [_backView removeFromSuperview];
    
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
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setValue:getHeaderData() forHTTPHeaderField:@"X-Insta-Forwarded-For"];
        [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                    UINavigationController *na = self.tabBarController.viewControllers[3];
                    PS_AchievementViewController *achievement = na.viewControllers[0];
                    achievement.uid = dataDic[@"id"];
                    achievement.userName = dataDic[@"username"];
                    achievement.userImage = dataDic[@"profile_picture"];
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                } errorBlock:^(NSError *errorR) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }];
                
            } errorBlock:^(NSError *errorR) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    };
    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:loginNC animated:YES completion:nil];
}

- (void)cancelLogin:(UIButton *)button
{
    [_loginAlert removeFromSuperview];
    [_backView removeFromSuperview];
}

//写的是滚动播放视频 现版本没视频
//- (void)playVideo
//{
//    NSArray *array = [_tableView visibleCells];
//    
//    for (PS_ImageDetailViewCell *cell in array) {
//        CGPoint point = [_tableView convertPoint:cell.center toView:self.view];
//        
//        if (CGRectContainsPoint(_tableView.frame, point)) {
//            NSLog(@"%f",cell.av.rate);
//            if (cell.av.status == AVPlayerStatusReadyToPlay ) {
//                NSLog(@"111");
//
//                [cell.av play];
//            }else{
////                NSString *str= [[NSBundle mainBundle] pathForResource:@"test" ofType:@"3gp"];
//                NSLog(@"222");
//                NSURL *sourceMovieURL = [NSURL fileURLWithPath:cell.model.media_pic];
//                AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
//                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//                [cell.av replaceCurrentItemWithPlayerItem:playerItem];
//                [cell.av play];
//            }
//        }else{
//            if (cell.av.status == AVPlayerStatusReadyToPlay) {
//                [cell.av pause];
//            }
//        }
//    }
//}
//
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    if(![scrollView isDecelerating] && ![scrollView isDragging]){
//        
//        [self playVideo];
//    }
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if(!decelerate){
//        
//        [self playVideo];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
