//
//  PS_SettingViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_SettingViewController.h"
#import "PS_UserViewCell.h"
#import "PS_LoginViewController.h"
#import "PS_AchievementViewController.h"

@interface PS_SettingViewController ()

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation PS_SettingViewController

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"appea");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor grayColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    label.text = LocalizedString(@"ps_set_setting", nil);
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:22.0];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    self.tableView.backgroundColor = colorWithHexString(@"#f0f0f0");
    [self.tableView registerNib:[UINib nibWithNibName:@"PS_UserViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"user"];

    _titleArray = @[@[@"ps_exp_login_title"],
                    @[@"setting_resolution"],
                    @[@"setting_rate",@"setting_feedback",@"setting_follow",@"setting_share"],
                    @[@"ps_set_privacy"]];
}

#pragma mark -- UITableViewDelegate  UITableViewDataSource--
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 17;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *subArray = _titleArray[section];
    return subArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 0 && [userDefault boolForKey:kIsLogin]) {
        PS_UserViewCell *cell = (PS_UserViewCell *)[tableView dequeueReusableCellWithIdentifier:@"user" forIndexPath:indexPath];
        cell.userNameLabel.text = [userDefault objectForKey:kUsername];
        [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:[userDefault objectForKey:kPic]] placeholderImage:[UIImage imageNamed:@"mr_head"]];
        cell.userImageView.layer.cornerRadius = 37/2.0;
        cell.userImageView.layer.masksToBounds = YES;
        cell.userDetailLabel.hidden = NO;
        cell.userDetailLabel.text = LocalizedString(@"ps_set_logout", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setting"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"setting"];
    }
    
    NSArray *subArray = _titleArray[indexPath.section];
    cell.textLabel.text = LocalizedString(subArray[indexPath.row], nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = colorWithHexString(@"#4b4b4b");
    cell.detailTextLabel.textColor = colorWithHexString(@"#797979");
    
    if (indexPath.section == 1) {
        cell.detailTextLabel.text = @"1024*1024";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin]) {
            //退出登录
            [self logOut];
            
        }else{
            //登录
            [self login];
        }
    }
    
    if (indexPath.section == 1) {
        
    }
    
    if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                
                break;
            case 1:
                
                break;
            case 2:
                
                break;
            case 3:
                
                break;
            default:
                break;
        }
    }
    
    if (indexPath.section == 3) {
        
    }
}

#pragma mark -- login --
- (void)login
{
    PS_LoginViewController *loginVC = [[PS_LoginViewController alloc] init];
    loginVC.loginSuccessBlock = ^(NSString *codeStr){
        
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
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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

- (void)logOut
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:LocalizedString(@"ps_set_logout", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [userDefault setBool:NO forKey:kIsLogin];
        [userDefault setObject:@"" forKey:kPic];
        [userDefault setObject:@"" forKey:kUsername];
        [userDefault setObject:@"" forKey:kUid];
        [userDefault setObject:@"" forKey:kAccessToken];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalizedString(@"ps_noti_cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:clearAction];
    [alert addAction:cancelAction];
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight)];
//    [self.view addSubview:view];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
