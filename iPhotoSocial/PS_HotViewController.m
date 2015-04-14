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
#import "PS_DataUtil.h"

#define kLoginViewHeight 50

@interface PS_HotViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) UIView * loginView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *mediasArray;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self requestMediasListWithMinID:0];
}

- (void)initSubViews
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 460;
    _tableView.delaysContentTouches = NO;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"PS_ImageDetailViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"imageDetail"];
    
    _loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, 50)];
    UIButton *button = [[UIButton alloc] initWithFrame:_loginView.bounds];
    [button setTitle:@"login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [_loginView addSubview:button];
    [self.view addSubview:_loginView];
}

- (void)addHeaderRefresh
{
    __weak PS_HotViewController *weakSelf = self;
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf.mediasArray removeAllObjects];
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
    NSDictionary *params = @{@"appId":@kPSAppid,@"uid":@1,@"count":@10,@"id":@(minID)};
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
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
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_tableView reloadData];
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
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    cell.followButton.tag = indexPath.row;
    [cell.followButton addTarget:self action:@selector(followBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.appButton.tag = indexPath.row;
    [cell.appButton addTarget:self action:@selector(appBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)followBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        PS_MediaModel *model = _mediasArray[button.tag];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateFollowUrl];
        NSDictionary *params = @{@"appId":@kPSAppid,
                                 @"uid":[userDefaults objectForKey:kUid],
                                 @"userName":[userDefaults objectForKey:kUsername],
                                 @"pic":[userDefaults objectForKey:kPic],
                                 @"followUid":model.uid};
        [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
            NSLog(@"follow%@",result);
        }];
    }
}

- (void)likeBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        PS_MediaModel *model = _mediasArray[button.tag];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateLikeUrl];
        NSDictionary *params = @{@"appId":@kPSAppid,
                                 @"uid":[userDefaults objectForKey:kUid],
                                 @"userName":[userDefaults objectForKey:kUsername],
                                 @"pic":[userDefaults objectForKey:kPic],
                                 @"followUid":model.uid,
                                 @"mediaId":model.mediaId};
        [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
            NSLog(@"like%@",result);
        }];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"not login" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self login:nil];
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    return isLogin;
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
                }];
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error = %@",error.description);
        }];
    };
    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:loginNC animated:YES completion:nil];
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
