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
#import "PS_DataRequest.h"
#import "MJRefresh.h"
#import "PS_DataUtil.h"

#define kLoginViewHeight 50

@interface PS_HotViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) UIView * loginView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *mediasArray;

@end

@implementation PS_HotViewController

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
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin];
    if (!isLogin) {
        _loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, 50)];
        UIButton *button = [[UIButton alloc] initWithFrame:_loginView.bounds];
        [button setTitle:@"login" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [_loginView addSubview:button];
        [self.view addSubview:_loginView];
    }
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
    NSDictionary *params = @{@"app_id":@kPSAppid,@"uid":@1,@"count":@2,@"id":@(minID)};
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSArray *listArr = resultDic[@"list"];
        if (listArr.count == 0) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"没有更多了";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:0.5];
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
    return self.mediasArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageDetail" forIndexPath:indexPath];
    
    PS_MediaModel *model = self.mediasArray[indexPath.row];
    cell.hotModel = model;
    
    cell.userButton.tag = indexPath.row;
    [cell.userButton addTarget:self action:@selector(userBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.followButton.tag = indexPath.row;
    [cell.followButton addTarget:self action:@selector(followBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    //    cell.app.tag = indexPath.row;
    //    [cell.userButton addTarget:self action:@selector(userClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)userBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        PS_MediaModel *model = self.mediasArray[button.tag];
        PS_AchievementViewController *achieveVC = [[PS_AchievementViewController alloc] init];
        achieveVC.uid = [NSString stringWithFormat:@"%@",model.uid];
        [self.navigationController pushViewController:achieveVC animated:YES];
    }
}

- (void)followBtnClick:(UIButton *)button
{
    [self followOrLike:0 index:button.tag];
}

- (void)likeBtnClick:(UIButton *)button
{
    [self followOrLike:1 index:button.tag];
}

- (void)followOrLike:(NSInteger)type index:(NSInteger)index
{
    if ([self showLoginAlertIfNotLogin]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        PS_MediaModel *model = _mediasArray[index];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateFollowLikeUrl];
        NSDictionary *params = @{@"app_id":@kPSAppid,
                                 @"uid":[userDefaults objectForKey:kUid],
                                 @"username":[userDefaults objectForKey:kUsername],
                                 @"pic":[userDefaults objectForKey:kPic],
                                 @"follow_uid":model.uid,
                                 @"classify":@0,
                                 @"type":@(type)};
        [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
            NSLog(@"follw%@",result);
        }];
    }
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
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"d31c225c691d41b393394966b4b3ad2b", @"client_id",
                                   @"token", @"response_type",//token
                                   @"igd31c225c691d41b393394966b4b3ad2b://authorize", @"redirect_uri",
                                   nil];
    //    if (self.scopes != nil) {
    //        NSString* scope = [self.scopes componentsJoinedByString:@"+"];
    [params setValue:@"relationships" forKey:@"scope"];
    //    }
    
    NSString *igAppUrl = [self serializeURL:@"https://instagram.com/oauth/authorize" params:params httpMethod:@"GET"];
    
    PS_LoginViewController *loginVC = [[PS_LoginViewController alloc] init];
    loginVC.urlStr = igAppUrl;
    loginVC.loginSuccessBlock = ^(NSString *tokenStr){
        _loginView.hidden = YES;
        
        //获取用户信息
        NSString *url = @"https://api.instagram.com/v1/users/self/";
        NSDictionary *params = @{@"access_token":tokenStr};
        
        [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"GET" block:^(NSObject *result) {
            
            NSLog(@"result = %@",result);
            NSDictionary *resultDic = (NSDictionary *)result;
            NSDictionary *dataDic = resultDic[@"data"];
            
            //记录用户信息
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:dataDic[@"id"] forKey:kUid];
            [userDefaults setObject:dataDic[@"username"] forKey:kUsername];
            [userDefaults setObject:dataDic[@"profile_picture"] forKey:kPic];
            [userDefaults setObject:tokenStr forKey:kAccessToken];
            [userDefaults setBool:YES forKey:kIsLogin];
            [userDefaults synchronize];
            
            UINavigationController *na = self.tabBarController.viewControllers[3];
            PS_AchievementViewController *achievement = na.viewControllers[0];
            achievement.uid = dataDic[@"id"];
            
            //注册到服务器
            NSString *registUrl = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSRegistUserInfoUrl];
            NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
            NSDictionary *registparams = @{@"uid":dataDic[@"id"],
                                           @"app_id":@20051,
                                           @"token":tokenStr,
                                           @"username":dataDic[@"username"],
                                           @"full_name":dataDic[@"full_name"],
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
            }];
        }];
    };
    
    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:loginNC animated:YES completion:nil];
}

- (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod {
    
    NSURL* parsedURL = [NSURL URLWithString:baseUrl];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
            ||([[params valueForKey:key] isKindOfClass:[NSData class]])) {
            if ([httpMethod isEqualToString:@"GET"]) {
                NSLog(@"can not use GET to upload a file");
            }
            continue;
        }
        NSString* escaped_value = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                        NULL, /* allocator */
                                                                                                        (__bridge CFStringRef)[params objectForKey:key],
                                                                                                        NULL, /* charactersToLeaveUnescaped */
                                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                        kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
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
