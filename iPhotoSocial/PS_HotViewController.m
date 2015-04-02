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

#define kLoginViewHeight 50

@interface PS_HotViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) UIView * loginView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *array;

@end

@implementation PS_HotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 460;
    _tableView.delaysContentTouches = NO;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"PS_ImageDetailViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"imageDetail"];
    
    BOOL isLogin = NO;
    CGFloat loginViewHeight = isLogin?0:kLoginViewHeight;
    
    _loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, loginViewHeight)];
    UIButton *button = [[UIButton alloc] initWithFrame:_loginView.bounds];
    [button setTitle:@"login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [_loginView addSubview:button];
    [self.view addSubview:_loginView];
    
    PS_MediaModel *model = [[PS_MediaModel alloc] init];
    model.type = 1;
    model.desc = @"a";
    model.media_pic= [[NSBundle mainBundle] pathForResource:@"test" ofType:@"3gp"];
    
    PS_MediaModel *model1 = [[PS_MediaModel alloc] init];
    model1.type = 2;
    model1.desc = @"sdhjshdfhjsdbjsbfjdsfjdsfsdfsdfdsfsdddddddddsdhjshdfhjsdbjsbfjdsfjdsfsdfsdfdsfsdddddddddsdhjshdfhjsdbjsbfjdsfjdsfsdfsdfdsfsdddddddddsdhjshdfhjsdbjsbfjdsfjdsfsdfsdfdsfsdddddddddsdhjshdfhjsdbjsbfjdsfjdsfsdfsdfdsfsddddddddd";
    model1.media_pic= [[NSBundle mainBundle] pathForResource:@"test" ofType:@"3gp"];

    PS_MediaModel *model2 = [[PS_MediaModel alloc] init];
    model2.type = 2;
    model2.desc = @"的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v";
    model2.media_pic= [[NSBundle mainBundle] pathForResource:@"test2" ofType:@"3gp"];

    PS_MediaModel *model3 = [[PS_MediaModel alloc] init];
    model3.type = 2;
    model3.desc = @"的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v";
    model3.media_pic= [[NSBundle mainBundle] pathForResource:@"test3" ofType:@"3gp"];

    self.array = @[model,model1,model2,model3];
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

#pragma mark -- UITableViewDelegate  UITableViewDataSource--
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageDetail" forIndexPath:indexPath];

    PS_MediaModel *model = self.array[indexPath.row];
    cell.model = model;
    
    cell.userButton.tag = indexPath.row;
    [cell.userButton addTarget:self action:@selector(userClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)userClick:(UIButton *)button
{
    PS_AchievementViewController *achieveVC = [[PS_AchievementViewController alloc] init];
    achieveVC.notMyself = YES;
    [self.navigationController pushViewController:achieveVC animated:YES];
}

- (void)playVideo
{
    NSArray *array = [_tableView visibleCells];
    
    for (PS_ImageDetailViewCell *cell in array) {
        CGPoint point = [_tableView convertPoint:cell.center toView:self.view];
        
        if (CGRectContainsPoint(_tableView.frame, point)) {
            NSLog(@"%f",cell.av.rate);
            if (cell.av.status == AVPlayerStatusReadyToPlay ) {
                NSLog(@"111");

                [cell.av play];
            }else{
//                NSString *str= [[NSBundle mainBundle] pathForResource:@"test" ofType:@"3gp"];
                NSLog(@"222");
                NSURL *sourceMovieURL = [NSURL fileURLWithPath:cell.model.media_pic];
                AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
                [cell.av replaceCurrentItemWithPlayerItem:playerItem];
                [cell.av play];
            }
        }else{
            if (cell.av.status == AVPlayerStatusReadyToPlay) {
                [cell.av pause];
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(![scrollView isDecelerating] && ![scrollView isDragging]){
        
        [self playVideo];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        
        [self playVideo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
