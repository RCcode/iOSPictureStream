//
//  ShopViewController.m
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "ShopViewController.h"
#import "StickerModel.h"
#import "ShopCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "ShopButton.h"
#import "AFHTTPRequestOperationManager.h"
#import "Reachability.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "StickerDataModel.h"
#import "Sticker_DataUtil.h"
#import "ShopBannerViewController.h"
#import "Sticker_SQLiteManager.h"

#define kCategoryButtonBaseTag 100
#define kWinWidth [UIScreen mainScreen].bounds.size.width
#define kWinHeight [UIScreen mainScreen].bounds.size.height
#define kBottomBarHeight 70
#define kStickerMaxSid @"StickerMaxSid"

#define kLastUseSticker @"lastUse"
#define kMaxRecentStickerNumber 50
#define kUmengEvent @"PhotoEdit_3"
@interface ShopViewController ()
{
    NSMutableArray *_stickerCategoryArray;
    NSMutableArray *_localStickerCategoryArray;
    NSArray *_currntCategoryArray;
    StickerModel *_currentSticker;
    NSDictionary *_dataDic;
    NSMutableArray *_btnArray;
    AFHTTPRequestOperationManager *_requestManager;
    UIButton *downloadBtn;
    UIImageView *spotImageView;
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self initNavigation];
    [self initView];
    
    // Do any additional setup after loading the view.
}

- (void)initNavigation
{
    [self.navigationController.navigationBar setBarTintColor:colorWithHexString(@"#5cbc99")];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = left;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.text = LocalizedString(@"main_sticker", nil);
    self.navigationItem.titleView = label;
    
}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initNavigation];
    [self initData];
    [self reloadView];
    [self doRequestShopData];
}

- (void)reloadView
{
    [self.collectionView reloadData];
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kWinWidth - kBottomBarHeight, kBottomBarHeight)];
    [_bottomBar addSubview:_scrollView];
    
    for (int i = 0; i < _stickerCategoryArray.count; i++) {
        ShopButton *button = [ShopButton buttonWithType:UIButtonTypeCustom];
        [button setNewTagForButton];
        StickerModel *sticker = _stickerCategoryArray[i];
        if (sticker.dataModel && sticker.dataModel.stickerIsLooked == 0) {
            button.shopTag.hidden = NO;
        }else{
            button.shopTag.hidden = YES;
        }
        if (i == 1) {
            button.isUse = YES;
        }
        [_btnArray addObject:button];
        [button setImage:sticker.preview forState:UIControlStateNormal];
        button.tag = kCategoryButtonBaseTag + i;
        [button addTarget:self action:@selector(categoryBtnOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(7 + i * (56 +7), 7, 56, 56)];
        [_scrollView addSubview:button];
    }
    [_scrollView setContentSize:CGSizeMake(_stickerCategoryArray.count * (56+ 7) + 7, 1)];
}


- (void)doRequestShopData
{
    NSDate *lastDate = nil;
    if (self.type == kStickerShop) {
        lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestPhotoMarkTime"];
    }else if (self.type == kBackgroundShop){
        lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestBackgroundTime"];
    }
    NSTimeInterval  timeInterval = [lastDate timeIntervalSinceNow];
    timeInterval = - timeInterval;
    if (lastDate == nil || timeInterval > 24 * 60 * 60)
    {
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
        
        if (![self checkNetWorking]){
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
            NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:kStickerMaxSid];
            if (number == nil) {
                [self setSpot];
            }
            for (NSDictionary *dic in resultArray) {
                StickerDataModel *dataModel = [[StickerDataModel alloc] init];
                dataModel.stickerId = ((NSNumber *)[dic objectForKey:@"id"]).intValue;
                if (number != nil) {
                    if (dataModel.stickerId > number.intValue) {
                        [self setSpot];
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
            //         NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestPhotoMarkTime"];
            if (self.type == kStickerShop) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"requestPhotoMarkTime"];
            }else if (self.type == kBackgroundShop){
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"requestBackgroundTime"];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (void)setSpot
{
    spotImageView.hidden = NO;
}

- (void)hideSopt
{
    spotImageView.hidden = YES;
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


- (void)initView
{
    _btnArray = [[NSMutableArray alloc] init];
    _bottomBar = [[UIView alloc] init];
    [_bottomBar setFrame:CGRectMake(0, kWinHeight- kBottomBarHeight , kWinWidth, kBottomBarHeight)];
    _bottomBar.backgroundColor = colorWithHexString(@"#eaeaea");
    [self.view addSubview:_bottomBar];
    downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadBtn setImage:[UIImage imageNamed:@"Sticker_store"] forState:UIControlStateNormal];
    [downloadBtn setBackgroundColor:colorWithHexString(@"5cbc99")];
    [downloadBtn addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
    [downloadBtn setFrame:CGRectMake(kWinWidth - kBottomBarHeight + 8, 8, kBottomBarHeight - 16, kBottomBarHeight - 16)];
    [_bottomBar addSubview:downloadBtn];
    spotImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"spot.png"]];
    spotImageView.frame = CGRectMake(downloadBtn.frame.size.width - 14 - 7, 15, 7, 7);
    spotImageView.tag = 10;
    spotImageView.hidden = YES;
    [downloadBtn addSubview:spotImageView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, kWinWidth, kWinHeight - kBottomBarHeight - 44) collectionViewLayout:layout];
    self.collectionView.backgroundColor = colorWithHexString(@"#b4dbcd");
    [self.collectionView registerClass:[ShopCollectionViewCell class] forCellWithReuseIdentifier:@"cellIde"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
}

- (void)categoryBtnOnClicked:(ShopButton *)btn
{
    if (btn.isUse) {
        
        return;
    }
    
//    [MobClick event:kUmengEvent label:[NSString stringWithFormat:@"photoedit_sticker_pack%ld",btn.tag - kCategoryButtonBaseTag]];
    
    for (ShopButton *button in _btnArray) {
        button.isUse = NO;
    }
    btn.isUse = YES;
    _currentSticker = nil;
    [self.collectionView reloadData];
    _currentSticker = _stickerCategoryArray[btn.tag - kCategoryButtonBaseTag];
    if (_currentSticker.dataModel.stickerIsLooked == 0) {
        _currentSticker.dataModel.stickerIsLooked = 1;
        btn.shopTag.hidden = YES;
        [self updataSqlForIsLooked];
    }
    [self.collectionView reloadData];
}

- (void)updataSqlForIsLooked
{
    if (_currentSticker.dataModel) {
        if (self.type == kStickerShop) {
            [[Sticker_SQLiteManager shareStance] updateSitckerInfo:_currentSticker.dataModel.stickerId withIsLooked:1 andType:@"sticker"];
        }else if (self.type == kBackgroundShop){
            [[Sticker_SQLiteManager shareStance] updateSitckerInfo:_currentSticker.dataModel.stickerId withIsLooked:1 andType:@"background"];
        }
    }
    
}

- (void)initData
{
    _localStickerCategoryArray = [[NSMutableArray alloc] init];
    StickerModel *localSticker1 = [[StickerModel alloc] init];
    localSticker1.preview = [UIImage imageNamed:@"com_rcplatform_sticker_packaged_sticker_cate_1"];
    _stickerCategoryArray = [[NSMutableArray alloc] init];
    //    if (self.type == kStickerShop) {
    localSticker1.urlArray = [[NSMutableArray alloc] initWithObjects:
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/01.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/02.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/03.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/04.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/05.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/06.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/07.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/08.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/09.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/10.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/11.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/12.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/13.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/14.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/15.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/16.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/17.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/18.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/19.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/20.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/21.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/22.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/23.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/24.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/25.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/26.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/27.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/28.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/29.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/30.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/31.png",
                              @"http://mimage.rcplatformhk.net/sticker/01Deco/32.png", nil];
    StickerModel *localSticker2 = [[StickerModel alloc] init];
    localSticker2.preview = [UIImage imageNamed:@"com_rcplatform_sticker_packaged_sticker_cate_2"];
    localSticker2.urlArray = [[NSMutableArray alloc] initWithObjects:
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/01.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/02.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/03.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/04.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/05.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/06.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/07.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/08.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/09.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/10.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/11.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/12.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/13.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/14.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/15.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/16.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/17.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/18.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/19.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/20.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/21.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/22.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/23.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/24.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/25.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/26.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/27.png",
                              @"http://mimage.rcplatformhk.net/sticker/02Pop/28.png", nil];
    StickerModel *localSticker3 = [[StickerModel alloc] init];
    localSticker3.preview = [UIImage imageNamed:@"com_rcplatform_sticker_packaged_sticker_cate_3"];
    localSticker3.urlArray = [[NSMutableArray alloc] initWithObjects:@"http://mimage.rcplatformhk.net/sticker/03White/01.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/02.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/03.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/04.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/05.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/06.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/07.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/08.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/10.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/11.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/12.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/13.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/14.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/15.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/17.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/18.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/19.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/20.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/21.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/22.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/23.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/24.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/25.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/26.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/27.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/28.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/29.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/30.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/31.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/32.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/33.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/34.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/35.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/36.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/38.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/39.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/40.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/41.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/42.png",
                              @"http://mimage.rcplatformhk.net/sticker/03White/44.png", nil];
    StickerModel *localSticker4 = [[StickerModel alloc] init];
    localSticker4.preview = [UIImage imageNamed:@"com_rcplatform_sticker_packaged_sticker_cate_4"];
    localSticker4.urlArray = [[NSMutableArray alloc] initWithObjects:@"http://mimage.rcplatformhk.net/sticker/04Words/01.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/02.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/03.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/04.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/05.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/06.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/07.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/08.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/09.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/10.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/11.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/12.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/13.png",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/14.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/15.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/16.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/17.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/18.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/19.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/20.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/21.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/22.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/23.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/24.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/25.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/26.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/27.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/28.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/29.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/30.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/31.PNG",
                              @"http://mimage.rcplatformhk.net/sticker/04Words/32.PNG" , nil];
    StickerModel *recentSitcker = [[StickerModel alloc] init];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSArray *temp = [user objectForKey:kLastUseSticker];
    NSMutableArray *lastUse = [[NSMutableArray alloc] initWithArray:temp];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    for (int i = 0; i < lastUse.count; i++) {
        NSString *string = lastUse[i];
        BOOL isCache = [manager cachedImageExistsForURL:[NSURL URLWithString:string]];
        UIImage *image = [UIImage imageWithContentsOfFile:string];
        
        if (!isCache && image == nil) {
            [lastUse removeObject:string];
            i --;
        }
    }
    
    recentSitcker.urlArray = [[NSMutableArray alloc] initWithArray:lastUse];
    
    recentSitcker.preview = [UIImage imageNamed:@"history"];
    [_localStickerCategoryArray addObject:recentSitcker];
    [_localStickerCategoryArray addObject:localSticker1];
    [_localStickerCategoryArray addObject:localSticker2];
    [_localStickerCategoryArray addObject:localSticker3];
    [_localStickerCategoryArray addObject:localSticker4];
    //    }
    [_stickerCategoryArray addObjectsFromArray:_localStickerCategoryArray];
    if (self.type == kStickerShop) {
        [Sticker_SQLiteManager shareStance].tableType = StickerType;
        NSArray *array = [[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"sticker"];
        [Sticker_DataUtil defaultDateUtil].stickerModelArray = array;
        for (StickerDataModel *model in [Sticker_DataUtil defaultDateUtil].stickerModelArray) {
            NSLog(@"model.sid = %d",model.stickerId);
            if (model.localDir.length > 2 && model.stickerDownloadTime > 0) {
                NSString *md5 = model.stickerMd5String;
                NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Sticker"];
                folderPath = [NSString stringWithFormat:@"%@/%@",folderPath,md5];
                NSLog(@"folderPath = %@",folderPath);
                NSFileManager * fm = [NSFileManager defaultManager];
                NSArray * files = [fm contentsOfDirectoryAtPath:folderPath error:nil];
                StickerModel *sticker = [[StickerModel alloc] init];
                sticker.dataModel = model;
                for (NSString *path in files) {
                    NSString *finalPath = [NSString stringWithFormat:@"%@/%@",folderPath,path];
                    NSRange pathRange = [finalPath rangeOfString:@"preview"];
                    if (pathRange.location == NSNotFound) {
                        [sticker.urlArray addObject:finalPath];
                    }else{
                        sticker.preview = [[UIImage alloc] initWithContentsOfFile:finalPath];
                    }
                }
                NSLog(@"add");
                [_stickerCategoryArray insertObject:sticker atIndex:1];
            }
        }
    }else{
        [Sticker_SQLiteManager shareStance].tableType = StickerType;
        NSArray *array = [[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"background"];
        [Sticker_DataUtil defaultDateUtil].stickerModelArray = array;
        for (StickerDataModel *model in [Sticker_DataUtil defaultDateUtil].stickerModelArray) {
            NSLog(@"model.sid = %d",model.stickerId);
            if (model.localDir.length > 2 && model.stickerDownloadTime > 0) {
                NSString *md5 = model.stickerMd5String;
                NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Background"];
                folderPath = [NSString stringWithFormat:@"%@/%@",folderPath,md5];
                NSLog(@"folderPath = %@",folderPath);
                NSFileManager * fm = [NSFileManager defaultManager];
                NSArray * files = [fm contentsOfDirectoryAtPath:folderPath error:nil];
                StickerModel *sticker = [[StickerModel alloc] init];
                sticker.dataModel = model;
                for (NSString *path in files) {
                    NSString *finalPath = [NSString stringWithFormat:@"%@/%@",folderPath,path];
                    NSRange pathRange = [finalPath rangeOfString:@"preview"];
                    if (pathRange.location == NSNotFound) {
                        [sticker.urlArray addObject:finalPath];
                    }else{
                        sticker.preview = [[UIImage alloc] initWithContentsOfFile:finalPath];
                    }
                }
                NSLog(@"add");
                [_stickerCategoryArray insertObject:sticker atIndex:1];
            }
        }
    }
    
    _currentSticker = _stickerCategoryArray[1];
    _currntCategoryArray = _currentSticker.urlArray;
    
}

- (void)download
{
//    [MobClick event:kUmengEvent label:@"photoedit_sticker_store"];
    [self hideSopt];
    ShopBannerViewController *bannerVC = [[ShopBannerViewController alloc] init];
    bannerVC.type = self.type;
    [self.navigationController pushViewController:bannerVC animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIde" forIndexPath:indexPath];
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *urlString = _currentSticker.urlArray[indexPath.row];
    NSRange httpRange = [urlString rangeOfString:@"http"];
    NSRange stickerRange = [urlString rangeOfString:@"Sticker"];
    NSRange backgroundRange = [urlString rangeOfString:@"Background"];
    if (httpRange.location != NSNotFound) {
        [cell.imageview sd_setImageWithURL:_currentSticker.urlArray[indexPath.row] placeholderImage:    [UIImage imageNamed:@"sticker_holder"] options:0];
    }else if (stickerRange.location != NSNotFound || backgroundRange.location != NSNotFound){
        
        NSURL *url = [NSURL fileURLWithPath:urlString];
        [cell.imageview sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"sticker_holder"] options:0];
    }
    
    //    });
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _currentSticker.urlArray ? _currentSticker.urlArray.count:0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = _currentSticker.urlArray[indexPath.row];
    NSRange httpRange = [urlString rangeOfString:@"http"];
    NSRange stickerRange = [urlString rangeOfString:@"Sticker"];
    NSRange backgroundRange = [urlString rangeOfString:@"Background"];
    if (httpRange.location != NSNotFound) {
        //        [cell.imageview sd_setImageWithURL:_currentSticker.urlArray[indexPath.row] placeholderImage:    [UIImage imageNamed:@"icon"] options:0];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        BOOL isCache = [manager cachedImageExistsForURL:[NSURL URLWithString:urlString]];
        if ([self.delegate respondsToSelector:@selector(stickerCallback:)] ) {
            if (!isCache) {
                [[[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"main_connect_failed", nil) delegate:nil cancelButtonTitle:LocalizedString(@"main_confirm", nil) otherButtonTitles:nil, nil]show];
                return;
            }
            [self.delegate performSelector:@selector(stickerCallback:) withObject:[NSURL URLWithString:urlString]];
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSArray *temp = [user objectForKey:kLastUseSticker];
            NSMutableArray *lastUse = [[NSMutableArray alloc] initWithArray:temp];
            
            for (int i = 0; i < lastUse.count; i++) {
                NSString *string = lastUse[i];
                if ([string isEqualToString:urlString]) {
                    [lastUse removeObject:string];
                    i --;
                }
            }
            
            //            for (NSString *string in lastUse) {
            //                if ([string isEqualToString:urlString]) {
            //                    [lastUse removeObject:string];
            //                }
            //            }
            
            [lastUse insertObject:urlString atIndex:0];
            if (lastUse.count > kMaxRecentStickerNumber) {
                [lastUse removeLastObject];
            }
            [user setObject:lastUse forKey:kLastUseSticker];
            [user synchronize];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (stickerRange.location != NSNotFound || backgroundRange.location != NSNotFound){
        
        NSURL *url = [NSURL fileURLWithPath:urlString];
        //        [cell.imageview sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"icon"] options:0];
        if ([self.delegate respondsToSelector:@selector(stickerCallback:)]) {
            [self.delegate performSelector:@selector(stickerCallback:) withObject:url];
            [self.navigationController popViewControllerAnimated:YES];
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSArray *temp = [user objectForKey:kLastUseSticker];
            NSMutableArray *lastUse = [[NSMutableArray alloc] initWithArray:temp];
            for (int i = 0; i < lastUse.count; i++) {
                NSString *string = lastUse[i];
                if ([string isEqualToString:urlString]) {
                    [lastUse removeObject:string];
                    i --;
                }
            }
            
            [lastUse insertObject:urlString atIndex:0];
            if (lastUse.count > kMaxRecentStickerNumber) {
                [lastUse removeLastObject];
            }
            [user setObject:lastUse forKey:kLastUseSticker];
            [user synchronize];
            
        }
    }
    
    
    
    
}

#pragma mark -
#pragma mark - UICollectionFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kWinWidth / 4 -1, kWinWidth / 4 - 1);
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
