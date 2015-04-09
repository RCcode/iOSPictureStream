//
//  showBannerViewController.m
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "PS_StoreViewController.h"
#import "ShopTableViewCell.h"
#import "Sticker_DataUtil.h"
#import "UIImageView+WebCache.h"
#import "StickerDataModel.h"
#import "PreviewViewController.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"
#import "Reachability.h"
#import "Sticker_SQLiteManager.h"
#import "DownloadManageViewController.h"

#define kWinWidth [UIScreen mainScreen].bounds.size.width
#define kWinHeight [UIScreen mainScreen].bounds.size.height
#define kStickerMaxSid @"StickerMaxSid"
#define kBackgroundMaxSid @"BackgroundMaxSid"
@interface PS_StoreViewController ()
{
    UITableView *_tableView;
    AFHTTPRequestOperationManager *_requestManager;
    NSMutableArray *_dataArray;
    UILabel *_label;
    NSNumber *_maxSid;
    int _maxTemp;
    UITableView *_backgroundTableView;
    NSMutableArray *_backgroundDataArray;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation PS_StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    [self initView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self initData];

}

- (void)initNavigation
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"s_setup"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button addTarget:self action:@selector(downloadManage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
    
    
}

- (void)downloadManage
{
    DownloadManageViewController *dVC = [[DownloadManageViewController alloc] init];
    dVC.type = (shopType )self.type;
    [self.navigationController pushViewController:dVC animated:YES];
    if (_maxTemp != 0) {
        _maxSid = [NSNumber numberWithInt:_maxTemp];
    }
    if (self.type == kPSStickerShop) {
        [[NSUserDefaults standardUserDefaults] setObject:_maxSid forKey:kStickerMaxSid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:_maxSid forKey:kBackgroundMaxSid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)initData
{
    _maxTemp = 0;
    _dataArray = [[NSMutableArray alloc] init];
    _backgroundDataArray = [[NSMutableArray alloc] init];
    if (self.type == kPSStickerShop) {
        _maxSid = [[NSUserDefaults standardUserDefaults] objectForKey:kStickerMaxSid];
        if (_maxSid == nil) {
            _maxSid = 0;
        }
    }else{
        _maxSid = [[NSUserDefaults standardUserDefaults] objectForKey:kBackgroundMaxSid];
        if (_maxSid == nil) {
            _maxSid = 0;
        }
    }
    _maxTemp = _maxSid.intValue;
    if (self.type == kPSStickerShop) {
        NSDate *lastDate = nil;
        lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestPhotoMarkTime"];
        NSTimeInterval  timeInterval = [lastDate timeIntervalSinceNow];
        timeInterval = - timeInterval;
        if ([[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"sticker"].count == 0 ||lastDate == nil || timeInterval > 24 * 60 * 60) {
            [self requestBannerData];
        }else{
            NSArray *array = [[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"sticker"];
            for (StickerDataModel *model in array) {
                if (model.stickerDownloadTime > 0 && model.localDir.length > 2) {
                    
                }else{
                    if (model.stickerId > _maxSid.intValue) {
                        _maxSid = [NSNumber numberWithInt:model.stickerId];
                        [[NSUserDefaults standardUserDefaults] setObject:_maxSid forKey:kStickerMaxSid];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
                    [_dataArray addObject:model];
                }
            }
            if (_dataArray.count == 0) {
                _label.hidden = NO;
            }
            [_tableView reloadData];
        }
    }else if (self.type == kPSBackgroundShop){
        NSDate *lastDate = nil;
        lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestBackgroundTime"];
        NSTimeInterval  timeInterval = [lastDate timeIntervalSinceNow];
        timeInterval = - timeInterval;
        if ([[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"background"].count == 0 || lastDate == nil || timeInterval > 24 * 60 * 60) {
            [self requestBannerData];
        }else{
            NSArray *array = [[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"background"];
            for (StickerDataModel *model in array) {
                if (model.stickerDownloadTime > 0 && model.localDir.length > 2) {
                    
                }else{
                    if (model.stickerId > _maxSid.intValue) {
                        _maxSid = [NSNumber numberWithInt:model.stickerId];
                        [[NSUserDefaults standardUserDefaults] setObject:_maxSid forKey:kBackgroundMaxSid];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
                    [_backgroundDataArray addObject:model];
                }
            }
            if (_backgroundDataArray.count == 0) {
                _label.hidden = NO;
            }
            [_backgroundTableView reloadData];
        }
    }
    
}

- (void)requestBannerData
{
    
    //    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestPhotoMarkTime"];
    
    
    //    if (lastDate == nil || timeInterval > 24 * 60 * 60)
    //    {
    [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    NSLog(@"begin downloading.......");
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray objectAtIndex:0];
    NSDictionary *dic;
    if (self.type == kStickerShop) {
        dic = [[NSDictionary alloc]initWithObjectsAndKeys:language,@"lang",@20051,@"appId",@0,@"plat",@0,@"type",nil];
    }
    else if (self.type == kBackgroundShop)
    {
        dic = [[NSDictionary alloc]initWithObjectsAndKeys:language,@"lang",@20051,@"appId",@0,@"plat",@1,@"type",nil];
    }
    //请求数据
    //    }
    if (![self checkNetWorking]){
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"无贴纸"]];
        imageview.frame = CGRectMake(0, 0, 84, 84);
        imageview.center = self.view.center;
        [self.view addSubview:imageview];
        return ;
    }
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setTimeoutInterval:30];
    
    NSString *urlString = @"http://inkpic.rcplatformhk.net/InkpicWeb/stickNew/getStickList.do";
    _requestManager = [[AFHTTPRequestOperationManager alloc] init];
    _requestManager.requestSerializer = requestSerializer;
    _requestManager.responseSerializer = responseSerializer;
    [_requestManager POST:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        NSDictionary *result = (NSDictionary *)responseObject;
        NSLog(@"result = %@",result);
        NSArray *resultArray = [result objectForKey:@"list"];
        NSArray *tempArray = [Sticker_DataUtil defaultDateUtil].stickerModelArray;
        for (NSDictionary *dic in resultArray) {
            
            StickerDataModel *dataModel = [[StickerDataModel alloc] init];
            dataModel.stickerId = ((NSNumber *)[dic objectForKey:@"id"]).intValue;
            if (self.type == kStickerShop) {
                if (dataModel.stickerId > _maxSid.intValue) {
                    _maxSid = [NSNumber numberWithInt:dataModel.stickerId];
                    [[NSUserDefaults standardUserDefaults] setObject:_maxSid forKey:kStickerMaxSid];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }else{
                if (dataModel.stickerId > _maxSid.intValue) {
                    _maxSid = [NSNumber numberWithInt:dataModel.stickerId];
                    [[NSUserDefaults standardUserDefaults] setObject:_maxSid forKey:kBackgroundMaxSid];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
            if(!(([[dic objectForKey:@"url"] isKindOfClass:[NSNull class]]) || ([dic objectForKey:@"url"] == nil)))
            {
                dataModel.stickerUrlString = [dic objectForKey:@"url"];
            }else{
                dataModel.stickerUrlString = @" ";
            }
            if(!(([[dic objectForKey:@"lurl"] isKindOfClass:[NSNull class]]) || ([dic objectForKey:@"lurl"] == nil)))
            {
                dataModel.stickerSmallUrlString = [dic objectForKey:@"lurl"];
                NSLog(@"dataModel.stickerSmallUrlString = %@",dataModel.stickerSmallUrlString);
            }else{
                dataModel.stickerSmallUrlString = @" ";
            }
            if(!(([[dic objectForKey:@"name"] isKindOfClass:[NSNull class]]) || ([dic objectForKey:@"name"] == nil)))
            {
                dataModel.stickerName = [dic objectForKey:@"name"];
            }else{
                dataModel.stickerName = @" ";
            }
            if(!(([[dic objectForKey:@"price"] isKindOfClass:[NSNull class]]) || ([dic objectForKey:@"price"] == nil)))
            {
                dataModel.stickerPrice = [dic objectForKey:@"price"];
            }else{
                dataModel.stickerPrice = @" " ;
            }
            dataModel.stickerSize = ((NSNumber *)[dic objectForKey:@"size"]).longValue;
            //            dataModel.stickerLastUpdateTime = ((NSNumber *)[dic objectForKey:@"updateTime"]).longValue;
            dataModel.stickerDownloadTime = 0;
            if(!(([[dic objectForKey:@"zipMd5"] isKindOfClass:[NSNull class]]) || ([dic objectForKey:@"zipMd5"] == nil)))
            {
                dataModel.stickerMd5String = [dic objectForKey:@"zipMd5"];
            }else{
                dataModel.stickerMd5String = @" ";
            }
            if(!(([[dic objectForKey:@"zipUrl"] isKindOfClass:[NSNull class]]) || ([dic objectForKey:@"zipUrl"] == nil)))
            {
                dataModel.stickerZipUrlString = [dic objectForKey:@"zipUrl"];
            }else{
                dataModel.stickerZipUrlString = @" " ;
            }
            dataModel.stickerIsLooked = 0;
            dataModel.localDir = @" ";
            [dataArray addObject:dataModel];
        }
        if (self.type == kStickerShop) {
            _dataArray = dataArray;
            [_tableView reloadData];
        }else if (self.type == kBackgroundShop){
            _backgroundDataArray = dataArray;
            [_backgroundTableView reloadData];
        }

        Sticker_SQLiteManager *sqliteManager = [Sticker_SQLiteManager shareStance];
        sqliteManager.tableType = StickerType;
        if (self.type == kStickerShop) {
            [sqliteManager deleteAllDataForStickerWithType:@"sticker"];
            [sqliteManager insertChatList:dataArray photoMarkType:@"sticker"];
        }else if (self.type == kBackgroundShop){
            [sqliteManager deleteAllDataForStickerWithType:@"background"];
            [sqliteManager insertChatList:dataArray photoMarkType:@"background"];
        }
        for (StickerDataModel *model in tempArray) {
            if (model.localDir.length > 2) {
                if (self.type == kStickerShop) {
                    [sqliteManager updateSitckerInfo:model.stickerId withIsLooked:model.stickerIsLooked andType:@"sticker"];
                    [sqliteManager updateStickerInfo:model.stickerId withDownloadDir:model.localDir andDownloadTime:model.stickerDownloadTime andType:@"sticker"];
                }else if (self.type == kBackgroundShop){
                    [sqliteManager updateSitckerInfo:model.stickerId withIsLooked:model.stickerIsLooked andType:@"background"];
                    [sqliteManager updateStickerInfo:model.stickerId withDownloadDir:model.localDir andDownloadTime:model.stickerDownloadTime andType:@"background"];
                }
            }
        }
        if (self.type == kStickerShop) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"requestPhotoMarkTime"];
        }else if (self.type == kBackgroundShop){
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"requestBackgroundTime"];
        }
        [MBProgressHUD hideAllHUDsForView:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"无贴纸"]];
        imageview.frame = CGRectMake(0, 0, 84, 84);
        imageview.center = self.view.center;
        [self.view addSubview:imageview];
        [MBProgressHUD hideAllHUDsForView:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    }];
    
    //    }
}

- (void)initView
{
    
    self.view.backgroundColor = [UIColor whiteColor];
//    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, windowWidth(), 62)];
//    topView.image = [UIImage imageNamed:@"top_bg"];
//    topView.userInteractionEnabled = YES;
//    [self.view addSubview:topView];
    
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, windowWidth() - 160, 44)];
//    if (self.type == kStickerShop) {
//        title.text = LocalizedString(@"main_sticker_store", nil);
//        
//    }else if (self.type == kBackgroundShop){
//        title.text = LocalizedString(@"main_background_store", nil);
//    }
//    title.textAlignment = NSTextAlignmentCenter;
//    title.textColor = [UIColor whiteColor];
//    title.adjustsFontSizeToFitWidth = YES;
//    title.minimumScaleFactor = 0.5;
//    title.font = [UIFont systemFontOfSize:20];
//    [topView addSubview:title];
    
    
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    [backButton setFrame:CGRectMake(0, 3, 44, 44)];
//    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:backButton];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, windowWidth(), 40)];
    _label.text = LocalizedString(@"main_no_update_sticker", nil);
    [self.view addSubview:_label];
    _label.hidden = YES;
    
//    UIButton *manageButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [manageButton setFrame:CGRectMake(windowWidth() - 16 - 22 - 8, 0, 44, 44)];
//    [manageButton setImage:[UIImage imageNamed:@"s_setup"] forState:UIControlStateNormal];
//    [manageButton addTarget:self action:@selector(downloadManage) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:manageButton];
    _backgroundTableView = [[UITableView alloc] initWithFrame:CGRectMake(kWindowWidth, 0, kWindowWidth + 1, kWindowHeight - 102)];
    _backgroundTableView.dataSource = self;
    _backgroundTableView.delegate = self;
    _backgroundTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWinWidth, kWinHeight - 102)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.view addSubview:_tableView];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 102, kWindowWidth, kWindowHeight - 74 - 40)];
    [self.view addSubview:_scrollView];
    [_scrollView addSubview:_tableView];
    [_scrollView addSubview:_backgroundTableView];
    [_scrollView setContentSize:CGSizeMake(kWindowWidth * 2, 0)];
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
//    _scrollView.alwaysBounceHorizontal = YES;
    
}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
    if (_maxTemp != 0) {
        _maxSid = [NSNumber numberWithInt:_maxTemp];
    }
    if (self.type == kStickerShop) {
        [[NSUserDefaults standardUserDefaults] setObject:_maxSid forKey:kStickerMaxSid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:_maxSid forKey:kBackgroundMaxSid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

#pragma mark -
#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"didEnd x = %f",scrollView.contentOffset.x);
    if (scrollView.contentOffset.y == 0) {
        if (scrollView.contentOffset.x == kWindowWidth) {
            NSLog(@"background");
            self.type = kBackgroundShop;
            [self initData];
        }else if (scrollView.contentOffset.x == 0){
            NSLog(@"sticke");
            self.type = kStickerShop;
            [self initData];
        }

    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"WillEndDragging x = %f",scrollView.contentOffset.x);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"WillBeginDragging x = %f",scrollView.contentOffset.x);
}

#pragma mark - 
#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 145;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIde = @"cellIde";
    ShopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell = [[ShopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    StickerDataModel *model = nil;
    if (tableView == _tableView) {
        model = [_dataArray objectAtIndex:indexPath.row];
    }else{
        model = [_backgroundDataArray objectAtIndex:indexPath.row];
    }
//    NSLog(@"_backgroundDataArray.count = %ld",_backgroundDataArray.count);
//    StickerDataModel *model = [_dataArray objectAtIndex:indexPath.row];
    NSString *urlString = model.stickerUrlString;
//    NSLog(@"urlString = %@",urlString);
    if (![urlString isKindOfClass:[NSNull class]]) {
        NSURL *url = [NSURL URLWithString:urlString];
        [cell.bannerView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"sticker_pic"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }
    if (model.stickerId > _maxTemp) {
        cell.tagView.hidden = NO;
    }else{
        cell.tagView.hidden = YES;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        return _dataArray.count;
    }else{
        return _backgroundDataArray.count;
    
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PreviewViewController *preVC = [[PreviewViewController alloc] init];
//    preVC.type = self.type;
    StickerDataModel *model = nil;
    if (tableView == _tableView) {
        preVC.type = (shopType)kStickerShop;
        model = [_dataArray objectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:_maxSid forKey:kStickerMaxSid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        preVC.type = (shopType)kBackgroundShop;
        model = [_backgroundDataArray objectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:_maxSid forKey:kBackgroundMaxSid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    preVC.dataModel = model;
    [self.navigationController pushViewController:preVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 检测网络状态
- (BOOL)checkNetWorking
{
    
    BOOL connected = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ? YES : NO;
    
    if (!connected) {
        
    }
    
    return connected;
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
