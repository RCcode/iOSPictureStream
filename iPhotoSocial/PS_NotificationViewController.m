//
//  PS_NotificationViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_NotificationViewController.h"
#import "PS_NotificationModel.h"
#import "RC_moreAPPsLib.h"
#import "PS_LoginView.h"
#import "PS_LoginViewController.h"
#import "PS_AchievementViewController.h"
#import "PS_UserViewCell.h"

@interface PS_NotificationViewController ()<UITableViewDataSource,UITableViewDelegate,LoginViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *notisArray;
@property (nonatomic, strong) PS_LoginView *loginView;

@end

@implementation PS_NotificationViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:HAVE_NEW_BACKGROUND]) {
        [self haveNewBackGround];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewBackGround) name:HAVE_NEW_BACKGROUND object:nil];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:HAVE_NEW_STICKER]) {
        [self haveNewSticker];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewSticker) name:HAVE_NEW_STICKER object:nil];
    }
    
    _notisArray = [[NSMutableArray alloc] initWithCapacity:1];
    [self initSubViews];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin]) {
        [self selectNotiFromFile];
        [self requestNotisficationList];
    }else{
        _loginView = [[PS_LoginView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, 44)  text:LocalizedString(@"ps_exp_login_text", nil)];
        _loginView.delegate = self;
        [self.view addSubview:_loginView];
    }
}

- (void)initSubViews
{
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more"] style:UIBarButtonItemStylePlain target:self action:@selector(moreAppButtonOnClick:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list_choice"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteAll:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    label.text = LocalizedString(@"ps_noti_notice", nil);
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:22.0];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"PS_UserViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"noti"];
}

- (void)haveNewBackGround
{
    PS_NotificationModel *model = [[PS_NotificationModel alloc] init];
    model.type = NotiTypeBackGround;
    [_notisArray insertObject:model atIndex:0];
    [_tableView reloadData];
}

- (void)haveNewSticker
{
    PS_NotificationModel *model = [[PS_NotificationModel alloc] init];
    model.type = NotiTypeSticker;
    [_notisArray insertObject:model atIndex:0];
    [_tableView reloadData];
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

- (void)requestNotisficationList
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetNoticeUrl];
    NSDictionary *params = @{@"appId":@(kPSAppid),
                             @"uid":[[NSUserDefaults standardUserDefaults] objectForKey:kUid],
                             @"type":@1};
    [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"888888%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        NSArray *listArray = resultDic[@"list"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (listArray == nil || [listArray isKindOfClass:[NSNull class]]) {
            [PS_DataUtil showPromptWithText:LocalizedString(@"ps_load_failed", nil)];
            return;
        }
        
        for (NSDictionary *dic in listArray) {
            PS_NotificationModel *model = [[PS_NotificationModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            [_notisArray addObject:model];
        }
        [_tableView reloadData];
        [self writeNotiToFile];
        
    } errorBlock:^(NSError *errorR) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [PS_DataUtil showPromptWithText:LocalizedString(@"ps_load_failed", nil)];
    }];
}

- (void)writeNotiToFile
{
    for (PS_NotificationModel *model in _notisArray) {
        NSMutableData *data = [NSMutableData dataWithCapacity:1];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:model forKey:[NSString stringWithFormat:@"%.0f",model.time]];
        [archiver finishEncoding];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *directoryPath = [documentPath stringByAppendingPathComponent:@"notification"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *filePath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0f",model.time]];
        [data writeToFile:filePath atomically:YES];
    }
}

- (void)selectNotiFromFile
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:@"notification"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
        for (NSString *fileName in arr) {
            if ([fileName isEqualToString:@".DS_Store"]) {
                continue;
            }
            NSData *data = [NSData dataWithContentsOfFile:[directoryPath stringByAppendingPathComponent:fileName]];
             NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            PS_NotificationModel *model = [unarchiver decodeObjectForKey:fileName];
            [unarchiver finishDecoding];
            [_notisArray insertObject:model atIndex:0];
        }
    }
}

#pragma mark -- UITableViewDelegate  UITableViewDataSource--
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_notisArray.count == 0) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _notisArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PS_UserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noti" forIndexPath:indexPath];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notification"];
//    }
    
    PS_NotificationModel *model = _notisArray[indexPath.row];
    cell.notiModel = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PS_NotificationModel *model = self.notisArray[indexPath.row];
    [self.notisArray removeObject:model];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    if (model.type != NotiTypeBackGround && model.type != NotiTypeSticker) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"notification/%.0f",model.time]];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (void)deleteAll:(UIBarButtonItem *)barButton
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:LocalizedString(@"ps_noti_clear_all", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.notisArray removeAllObjects];
        [_tableView reloadData];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [documentPath stringByAppendingPathComponent:@"notification"];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalizedString(@"ps_noti_cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:clearAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
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
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                }];
                
            } errorBlock:^(NSError *errorR) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
