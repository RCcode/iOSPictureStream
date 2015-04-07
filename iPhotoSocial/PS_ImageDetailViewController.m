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
#import "PS_DataRequest.h"

@interface PS_ImageDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) UIView *loginView;

@end

@implementation PS_ImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Photo";
    
    [self initSubViews];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken]) {
        
        if (_model != nil) {
            [self requestMediaDesc];
        }
    }
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

#pragma mark -- 获取发现图片描述 --
- (void)requestMediaDesc
{
    //            @"https://api.instagram.com/v1/media/{media-id}?access_token=ACCESS-TOKEN"
    NSString *mediaUrl = [NSString stringWithFormat:@"%@%@",@"https://api.instagram.com/v1/media/",_model.media_id];
    NSDictionary *mediaParams = @{@"access_token":[[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken]};
    
    [PS_DataRequest requestWithURL:mediaUrl params:[mediaParams mutableCopy] httpMethod:@"GET" block:^(NSObject *result) {
        NSLog(@"5555%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSDictionary *resultData = resultDic[@"data"];
        _model.media_desc = resultData[@"caption"][@"text"];
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

    return cell;
}

- (void)userBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        PS_AchievementViewController *achieveVC = [[PS_AchievementViewController alloc] init];
        achieveVC.uid = [NSString stringWithFormat:@"%@",_model?_model.uid:_instragramModel.uid];
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
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSUpdateFollowLikeUrl];
        NSDictionary *params = @{@"app_id":@kPSAppid,
                                 @"uid":[userDefaults objectForKey:kUid],
                                 @"username":[userDefaults objectForKey:kUsername],
                                 @"pic":[userDefaults objectForKey:kPic],
                                 @"follow_uid":_model?_model.uid:_instragramModel.uid,
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
            //获取描述
            [self requestMediaDesc];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
