//
//  PS_findViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_DiscoverViewController.h"
#import "PS_ImageCollectionViewCell.h"
#import "PS_ImageDetailViewController.h"
#import "PS_AchievementViewController.h"
#import "PS_LoginViewController.h"
#import "RC_moreAPPsLib.h"
#import "PS_DataRequest.h"
#import "PS_MediaModel.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "PS_DataUtil.h"

#define kLoginViewHeight 50

@interface PS_DiscoverViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *loginView;
@property (nonatomic, strong) UICollectionView *collect;
@property (nonatomic, strong) NSMutableArray * mediasArray;

@end

@implementation PS_DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initSubViews];
    [self addHeaderRefresh];
    [self addfooterRefresh];

    _mediasArray = [[NSMutableArray alloc] initWithCapacity:1];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self requestMediasListWithTeams:nil];
}

- (void)initSubViews
{
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"mpreAPP" style:UIBarButtonItemStylePlain target:self action:@selector(moreAppButtonOnClick:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
//    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    _collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) collectionViewLayout:layout];
    _collect.backgroundColor = [UIColor whiteColor];
    _collect.dataSource = self;
    _collect.delegate = self;
    [self.view addSubview:_collect];
    
    [_collect registerClass:[PS_ImageCollectionViewCell class] forCellWithReuseIdentifier:@"discover"];
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin];
    if (!isLogin) {
        _loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, 50)];
        [self.view addSubview:_loginView];
        UIButton *button = [[UIButton alloc] initWithFrame:_loginView.bounds];
        [button setTitle:@"login" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [_loginView addSubview:button];
    }
}

- (void)addHeaderRefresh
{
    __weak PS_DiscoverViewController *weakSelf = self;
    [_collect addLegendHeaderWithRefreshingBlock:^{
        NSLog(@"header");
        [weakSelf.mediasArray removeAllObjects];
        [weakSelf requestMediasListWithTeams:nil];
    }];
    _collect.header.updatedTimeHidden = YES;
    _collect.header.stateHidden = YES;
}

- (void)addfooterRefresh
{
    __weak PS_DiscoverViewController *weakSelf = self;
    [_collect addLegendFooterWithRefreshingBlock:^{
        NSLog(@"footer");
        [weakSelf requestMediasListWithTeams:[PS_DataUtil defaultDateUtil].c_teamArray];
    }];
    _collect.footer.stateHidden = YES;
    [_collect.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
}

#pragma mark -- 数据请求 --
- (void)requestMediasListWithTeams:(NSMutableArray *)c_team
{
    NSDictionary *params = nil;
    if (c_team == nil) {
        params = @{@"app_id":@kPSAppid,@"uid":@1};
    }else{
        params = @{@"app_id":@kPSAppid,@"uid":@1,@"c_teams":[PS_DataUtil defaultDateUtil].c_teamArray};
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetExplorListUrl];
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"%@",result);
        NSDictionary *resultDic = (NSDictionary *)result;
        [PS_DataUtil defaultDateUtil].c_teamArray = resultDic[@"c_teams"];
        NSArray *listArr = resultDic[@"list"];
        
        if (listArr.count == 0) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"没有更多了";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:0.5];
        }else{
            for (NSDictionary *dic in listArr) {
                PS_MediaModel *model = [[PS_MediaModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [_mediasArray addObject:model];
            }
        }
        
        [_collect.header endRefreshing];
        [_collect.footer endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_collect reloadData];
    }];
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

#pragma mark -- UICollectionViewDataSource UICollectionViewDelegate --

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _mediasArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discover" forIndexPath:indexPath];

    PS_MediaModel *model = _mediasArray[indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.media_pic] placeholderImage:[UIImage imageNamed:@"a"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error && error.code == 404) {
            NSLog(@"44444%@",model.media_id);
            NSLog(@"图片已删除");
        }
    }];
    cell.tagLabel.hidden = YES;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    PS_ImageDetailViewController *deteilVC = [[PS_ImageDetailViewController alloc] init];
    deteilVC.model = _mediasArray[indexPath.row];
    [self.navigationController pushViewController:deteilVC animated:YES];
}

#pragma mark -- login --
- (void)login:(UIButton *)button
{
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"d31c225c691d41b393394966b4b3ad2b", @"client_id",
//                                   @"token", @"response_type",//token
//                                   @"igd31c225c691d41b393394966b4b3ad2b://authorize", @"redirect_uri",
//                                   nil];
    //    if (self.scopes != nil) {
    //        NSString* scope = [self.scopes componentsJoinedByString:@"+"];
//    [params setValue:@"relationships" forKey:@"scope"];
    //    }
    
//    NSString *igAppUrl = [self serializeURL:@"https://instagram.com/oauth/authorize" params:params httpMethod:@"POST"];
    
//    NSString *loginUrl = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=code&scope=likes+relationships",kClientId,kRedirectUri];
    
    
    NSString *loginUrl = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=code&scope=likes+relationships",@"4e483786559e48bf912b7926843c074a",@"http://"];

    
    PS_LoginViewController *loginVC = [[PS_LoginViewController alloc] init];
    loginVC.urlStr = loginUrl;
    loginVC.loginSuccessBlock = ^(NSString *codeStr){
        _loginView.hidden = YES;
        
        NSString *url = @"https://api.instagram.com/oauth/access_token?scope=likes+relationships";
        NSDictionary *params = @{@"client_id":kClientId,
                                 @"client_secret":kClientSecret,
                                 @"grant_type":@"authorization_code",
                                 @"redirect_uri":kRedirectUri,
                                 @"code":codeStr};
        [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
            NSLog(@"loginresult  %@",result);
        }];
        
        
        
        
        
//        //获取用户信息
//        NSString *url = @"https://api.instagram.com/v1/users/self/";
//        NSDictionary *params = @{@"access_token":};
//        
//        [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"GET" block:^(NSObject *result) {
//            
//            NSLog(@"result = %@",result);
//            NSDictionary *resultDic = (NSDictionary *)result;
//            NSDictionary *dataDic = resultDic[@"data"];
//            
//            //记录用户信息
//            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//            [userDefaults setObject:dataDic[@"id"] forKey:kUid];
//            [userDefaults setObject:dataDic[@"username"] forKey:kUsername];
//            [userDefaults setObject:dataDic[@"profile_picture"] forKey:kPic];
//            [userDefaults setObject:tokenStr forKey:kAccessToken];
//            [userDefaults setBool:YES forKey:kIsLogin];
//            [userDefaults synchronize];
//            
//            UINavigationController *na = self.tabBarController.viewControllers[3];
//            PS_AchievementViewController *achievement = na.viewControllers[0];
//            achievement.uid = dataDic[@"id"];
//            
//            //注册到服务器
//            NSString *registUrl = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSRegistUserInfoUrl];
//            NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
//            NSDictionary *registparams = @{@"uid":dataDic[@"id"],
//                                           @"app_id":@20051,
//                                           @"token":tokenStr,
//                                           @"username":dataDic[@"username"],
//                                           @"full_name":dataDic[@"full_name"],
//                                           @"pic":dataDic[@"profile_picture"],
//                                           @"bio":dataDic[@"bio"],
//                                           @"website":dataDic[@"website"],
//                                           @"media":dataDic[@"counts"][@"media"],
//                                           @"follows":dataDic[@"counts"][@"follows"],
//                                           @"followed":dataDic[@"counts"][@"followed_by"],
//                                           @"language":language,
//                                           @"plat":@0};
//            
//            [PS_DataRequest requestWithURL:registUrl params:[registparams mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
//                NSLog(@"qqqqqqqq%@",result);
//            }];
//        }];
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
