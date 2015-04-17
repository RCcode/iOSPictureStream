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
#import "PS_UserListTableViewController.h"
#import "PS_RepostViewController.h"
#import "AFNetworking.h"
#import "PS_LoginAlertView.h"

@interface PS_ImageDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) UIView *loginView;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) AFURLSessionManager *downloadManager;
@property (nonatomic, strong) PS_LoginAlertView *loginAlert;
@property (nonatomic, strong) UIView *backView;

@end

@implementation PS_ImageDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PS_ImageDetailViewCell *cell = [[_tableView visibleCells] lastObject];
    [cell.av play];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    PS_ImageDetailViewCell *cell = [[_tableView visibleCells] lastObject];
    [cell.av pause];
    [cell.av seekToTime:kCMTimeZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
//    label.text = @"Photo";
//    label.textColor = [UIColor whiteColor];
//    label.font = [UIFont fontWithName:@"Raleway-Thin" size:22.0];
//    label.textAlignment = NSTextAlignmentCenter;
//    self.navigationItem.titleView = label;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"t_photo"]];
    self.navigationItem.titleView = imageView;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    [self initSubViews];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self requestLikesCountWithID:_model!= nil?_model.mediaId:_instragramModel.media_id];
    [self downloadVideo];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin]) {
        //检测是否like过这个media  从而设置like按钮是否可点
        [self requestIsLikedThisMediaWithMediaID:_model!= nil?_model.mediaId:_instragramModel.media_id];
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
    
//    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin];
//    if (!isLogin) {
//        _loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, 50)];
//        UIButton *button = [[UIButton alloc] initWithFrame:_loginView.bounds];
//        [button setTitle:@"login" forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
//        button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//        [_loginView addSubview:button];
//        [self.view addSubview:_loginView];
//    }
}

- (void)requestLikesCountWithID:(NSString *)mediaID
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetLikesCountUrl];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@kPSAppid,@"appId",mediaID,@"mediaId", nil];
    [params setValue:[[NSUserDefaults standardUserDefaults] objectForKey:kUid] forKey:@"uid"];
    
    [PS_DataRequest requestWithURL:url params:params httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"ssss%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        if (_model != nil) {
            _model.likes = [NSString stringWithFormat:@"%@",resultDic[@"likes"]];
        }else{
        _instragramModel.likesCount = [NSString stringWithFormat:@"%@",resultDic[@"likes"]];
        _instragramModel.packName = resultDic[@"packName"];
        _instragramModel.downUrl = resultDic[@"downUrl"];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_tableView reloadData];
    } errorBlock:^(NSError *errorR) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)requestIsLikedThisMediaWithMediaID:(NSString *)mediaID
{
    NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@",mediaID];
    NSDictionary *params = @{@"access_token":[[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken]};
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"GET" block:^(NSObject *result) {
        NSLog(@"ssssddddddddd%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        PS_ImageDetailViewCell *cell = [_tableView.visibleCells lastObject];
        cell.likeButton.enabled = [resultDic[@"data"][@"user_has_liked"] boolValue]==0?YES:NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } errorBlock:^(NSError *errorR) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)downloadVideo
{
    NSString *urlStr = nil;
    if (_model != nil) {
        if ([_model.mediaUrl isEqualToString:@""] == NO) {
            urlStr = _model.mediaUrl;
        }
    }
    
    if (_instragramModel != nil) {
        urlStr = _instragramModel.videos[@"standard_resolution"][@"url"];
    }
    
    if (urlStr == nil) {
        return;
    }
    
    NSLog(@"urlStr === %@",urlStr);
    //先下载视频再播放
    _downloadManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSProgress *p = nil;
    NSURLSessionDownloadTask *task = [_downloadManager downloadTaskWithRequest:request progress:&p destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *directorPath = [documentPath stringByAppendingPathComponent:@"Download"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:directorPath]) {
            [fileManager createDirectoryAtPath:directorPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *filePath = [directorPath stringByAppendingPathComponent:[response suggestedFilename]];
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"filePath == %@",filePath);
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }else{
            if (_model != nil) {
                _model.localFilePath = filePath;
            }
            if (_instragramModel != nil) {
                _instragramModel.localFilePath = filePath;
            }
            
            PS_ImageDetailViewCell *cell = [[_tableView visibleCells] lastObject];
            AVAsset *assert =[AVAsset assetWithURL:filePath];
            AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:assert];
            [cell.av replaceCurrentItemWithPlayerItem:item];
            [cell.av play];
        }
    }];
    
    [_downloadManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"%f",(float)totalBytesWritten/(float)totalBytesExpectedToWrite);
    }];
    [task  resume];
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
        } errorBlock:^(NSError *errorR) {
            
        }];
    }
}

- (void)likeBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        button.enabled = NO;

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        PS_ImageDetailViewCell *cell = (PS_ImageDetailViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
        cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld",cell.likeCountLabel.text.integerValue + 1];
        
        //Instragram先like
        NSString *likeUrl = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes",_model!= nil?_model.mediaId:_instragramModel.media_id];
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
                                         @"likeUid":_model!=nil?_model.uid:_instragramModel.uid,
                                         @"mediaId":_model!=nil?_model.mediaId:_instragramModel.media_id,
                                         @"tag":_model!= nil?_model.tag:@"rcnocrop"};
                [PS_DataRequest requestWithURL:urlStr params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
                    NSLog(@"like%@",result);
                    NSDictionary *resultDic = (NSDictionary *)result;
                    if ([resultDic[@"stat"] integerValue] == 10000) {
                        NSLog(@"成功");
                    }else{
                        NSLog(@"失败");
                        cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld",cell.likeCountLabel.text.integerValue - 1];
                    }
                } errorBlock:^(NSError *errorR) {
                    NSLog(@"%@",errorR.localizedDescription);
                }];
                
            }else{
                cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld",cell.likeCountLabel.text.integerValue - 1];
                button.enabled = YES;
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld",cell.likeCountLabel.text.integerValue - 1];
            button.enabled = YES;
        }];
    }
}

- (void)likesListBtnClick:(UIButton *)button
{
    if ([self showLoginAlertIfNotLogin]) {
        PS_UserListTableViewController *userListVC = [[PS_UserListTableViewController alloc] init];
        userListVC.uid = _model!= nil?_model.uid:_instragramModel.uid;
        userListVC.type = UserListTypeLike;
        userListVC.mediaID = _model!= nil?_model.mediaId:_instragramModel.media_id;
        [self.navigationController pushViewController:userListVC animated:YES];
    }
}

- (void)appBtnClick:(UIButton *)button
{
    NSLog(@"aaaaa%@",_model.downUrl);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_model.downUrl]];
}

- (void)repostBtnClick:(UIButton *)button
{
    PS_RepostViewController *repostVC = [[PS_RepostViewController alloc] init];
    if (_model != nil) {
        repostVC.mModel = _model;
        repostVC.type = kComeFromServer;
    }else{
        repostVC.insModel = _instragramModel;
        repostVC.type = kComeFromInstragram;
    }
    [repostVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:repostVC animated:YES];
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
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }];
                
            }errorBlock:^(NSError *errorR) {
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

- (void)cancelLogin:(UIButton *)button
{
    [_loginAlert removeFromSuperview];
    [_backView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
