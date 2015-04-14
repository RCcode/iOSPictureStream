//
//  PS_ImageDetailViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_ImageDetailViewController.h"
#import "PS_ImageDetailViewCell.h"
#import "PS_LoginViewController.h"
#import "PS_AchievementViewController.h"

@interface PS_ImageDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) UIView *loginView;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end

@implementation PS_ImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 93, 28)];
    label.text = @"Photo";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:22];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    [self initSubViews];
    if (_instragramModel != nil) {
        [self requestLikesCountWithID:_instragramModel.media_id];
    }
}

- (void)backBtnClick:(UIBarButtonItem *)barButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initSubViews
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.delaysContentTouches = NO;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 460;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"PS_ImageDetailViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"imageDetail"];
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] objectForKey:kIsLogin];
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

//#pragma mark -- 获取发现图片描述 --
//- (void)requestMediaDesc
//{
//    //            @"https://api.instagram.com/v1/media/{media-id}?access_token=ACCESS-TOKEN"
//    NSString *mediaUrl = [NSString stringWithFormat:@"%@%@",@"https://api.instagram.com/v1/media/",_model.mediaId];
//    NSDictionary *mediaParams = @{@"access_token":[[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken]};
//    
//    [PS_DataRequest requestWithURL:mediaUrl params:[mediaParams mutableCopy] httpMethod:@"GET" block:^(NSObject *result) {
//        NSLog(@"5555%@",result);
//        NSDictionary *resultDic = (NSDictionary *)result;
//        NSDictionary *resultData = resultDic[@"data"];
//        _model.mediaDesc = resultData[@"caption"][@"text"];
//        [_tableView reloadData];
//    }];
//}

- (void)requestLikesCountWithID:(NSString *)mediaID
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetLikesCountUrl];
    NSDictionary *params = @{@"appId":@kPSAppid,
                             @"uid":[[NSUserDefaults standardUserDefaults] objectForKey:kUid],
                             @"mediaId":mediaID};
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"ssssddddddddd%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        _instragramModel.likesCount = [NSString stringWithFormat:@"%@",resultDic[@"likes"]];
        _instragramModel.packName = resultDic[@"packName"];
        _instragramModel.downUrl = resultDic[@"downUrl"];
        [_tableView reloadData];
    }];
}

#pragma mark -- UITableViewDelegate  UITableViewDataSource --
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageDetail" forIndexPath:indexPath];
    
    if (_model != nil) {
        cell.model = _model;
    }else{
        cell.instragramModel = _instragramModel;
    }
    
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
        PS_AchievementViewController *achieveVC = [[PS_AchievementViewController alloc] init];
        achieveVC.uid = _model?_model.uid:_instragramModel.uid;
        achieveVC.userImage = _model?_model.pic:_instragramModel.profile_picture;
        achieveVC.userName = _model?_model.userName:_instragramModel.username;
        [self.navigationController pushViewController:achieveVC animated:YES];
    }
}

- (void)followBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateFollowUrl];
        NSDictionary *params = @{@"appId":@kPSAppid,
                                 @"uid":[userDefaults objectForKey:kUid],
                                 @"userName":[userDefaults objectForKey:kUsername],
                                 @"pic":[userDefaults objectForKey:kPic],
                                 @"followUid":_model!=nil?_model.uid:_instragramModel.uid};
        [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
            NSLog(@"follow%@",result);
        }];
    }
}

- (void)likeBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateLikeUrl];
        NSDictionary *params = @{@"appId":@kPSAppid,
                                 @"uid":[userDefaults objectForKey:kUid],
                                 @"userName":[userDefaults objectForKey:kUsername],
                                 @"pic":[userDefaults objectForKey:kPic],
                                 @"followUid":_model!=nil?_model.uid:_instragramModel.uid,
                                 @"mediaId":_model!=nil?_model.mediaId:_instragramModel.media_id};
        [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
            NSLog(@"like%@",result);
        }];
    }
}

- (void)appBtnClick:(UIButton *)button
{
    NSLog(@"aaaaa%@",_model.downUrl);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_model.downUrl]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
