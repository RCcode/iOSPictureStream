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
#import "PS_LoginViewController.h"
#import "RC_moreAPPsLib.h"
#import "PS_DataRequest.h"

#define kLoginViewHeight 50

@interface PS_DiscoverViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *loginView;
@property (nonatomic, strong) UICollectionView *collect;
@property (nonatomic, strong) NSMutableArray * imagesUrlArray;

@end

@implementation PS_DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"mpreAPP" style:UIBarButtonItemStylePlain target:self action:@selector(moreAppButtonOnClick:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    _collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) collectionViewLayout:layout];
    _collect.backgroundColor = [UIColor redColor];
    _collect.dataSource = self;
    _collect.delegate = self;
    [self.view addSubview:_collect];
    
    [_collect registerClass:[PS_ImageCollectionViewCell class] forCellWithReuseIdentifier:@"discover"];
    
    BOOL isLogin = NO;
    CGFloat loginViewHeight = isLogin?0:kLoginViewHeight;
    
    _loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, loginViewHeight)];
    [self.view addSubview:_loginView];
    UIButton *button = [[UIButton alloc] initWithFrame:_loginView.bounds];
    [button setTitle:@"login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [_loginView addSubview:button];

    _imagesUrlArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kPSBaseUrl,kPSGetExplorListUrl];
    NSDictionary *params = @{@"app_id":@22015,
                                @"uid":@1};
    [PS_DataRequest requestWithURL:url params:[params mutableCopy] httpMethod:@"POST" block:^(NSObject *result) {
        NSLog(@"%@",result);
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

#pragma mark -- UICollectionViewDataSource UICollectionViewDelegate --

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discover" forIndexPath:indexPath];
    [cell setimage:[UIImage imageNamed:@"a"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    PS_ImageDetailViewController *deteilVC = [[PS_ImageDetailViewController alloc] init];
    [self.navigationController pushViewController:deteilVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
