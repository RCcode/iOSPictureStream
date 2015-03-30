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

@interface PS_DiscoverViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end

@implementation PS_DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"mpreAPP" style:UIBarButtonItemStylePlain target:self action:@selector(moreAppButtonOnClick:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    BOOL isLogin = NO;
    CGFloat loginViewHeight = isLogin?0:50;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, loginViewHeight)];
    [button setTitle:@"login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor greenColor];
    [self.view addSubview:button];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    UICollectionView *collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, loginViewHeight, kWindowWidth, kEditFrameHeight - loginViewHeight) collectionViewLayout:layout];
    collect.backgroundColor = [UIColor redColor];
    collect.dataSource = self;
    collect.delegate = self;
    [self.view addSubview:collect];
    
    [collect registerClass:[PS_ImageCollectionViewCell class] forCellWithReuseIdentifier:@"discover"];
}

- (void)moreAppButtonOnClick:(UIBarButtonItem *)barButotn
{
    UIViewController *moreVC = [[UIViewController alloc] init];
    moreVC.title = @"more app";
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonOnClick:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:moreVC];
    [self presentViewController:na animated:YES completion:nil];
}

- (void)closeButtonOnClick:(UIBarButtonItem *)barButton
{
    
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:igAppUrl]];
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

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
    PS_ImageDetailViewController *deteilVC = [[PS_ImageDetailViewController alloc] init];
    [self.navigationController pushViewController:deteilVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
