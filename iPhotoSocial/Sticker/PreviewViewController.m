//
//  PreviewViewController.m
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/1.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "PreviewViewController.h"
#import "UIImageView+WebCache.h"
#import "ShopCollectionViewCell.h"
#import "AFHTTPRequestOperationManager.h"
#import "THProgressView.h"
#import "MD5Tools.h"
#import "ZipArchive.h"
#import "Sticker_SQLiteManager.h"
#import "ASProgressPopUpView.h"
//#import "NC_MainViewController.h"

#define kWinWidth [UIScreen mainScreen].bounds.size.width
#define kWinHeight [UIScreen mainScreen].bounds.size.height

@interface PreviewViewController ()
{
    NSMutableArray *_dataArray;
    AFHTTPRequestOperationManager *_requestManager;
//    UIView *_bottomView;
    
    THProgressView *_progressView;
    //    ASProgressPopUpView *_asProgressView;
    long long totalBytes;
    
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic, strong) ASProgressPopUpView *asProgressView;
@property (nonatomic, assign) BOOL isDownload;
@property (nonatomic,strong) UIButton *completeBtn;
@property (nonatomic, strong)  UIImageView *downloadView;
@property (nonatomic, strong )AFHTTPRequestOperation *operation;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSString *finalFileName;
@property (nonatomic, strong) NSString *filefo;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation PreviewViewController
@synthesize connection = connection;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    [self initView];
    [self initData];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)initNavigation
{
    
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, windowWidth(), 62)];
    topView.image = [UIImage imageNamed:@"top_bg"];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0, 0, 44, 44)];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, windowWidth() - 160, 44)];
    title.text = self.dataModel.stickerName;
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.adjustsFontSizeToFitWidth = YES;
    title.minimumScaleFactor = 0.5;
    title.font = [UIFont systemFontOfSize:20];
    [topView addSubview:title];
    
}

- (void)back:(UIButton *)btn
{
    if (_isDownload) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"main_cancel_download", nil) delegate:self cancelButtonTitle:LocalizedString(@"main_cancel", nil) otherButtonTitles:LocalizedString(@"main_confirm", nil), nil];
        [alert show];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
//        [_operation cancel];
        [connection cancel];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)initData
{
    _isDownload = NO;
    _dataArray = [[NSMutableArray alloc] init];
    int stickerId = self.dataModel.stickerId;
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:stickerId],@"stickId", nil];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setTimeoutInterval:30];
    //http://inkpic.rcplatformhk.net/InkpicWeb/stickNew/getStickList.do
    NSString *urlString = @"http://inkpic.rcplatformhk.net/InkpicWeb/stickNew/getStickThumb.do";
    _requestManager = [[AFHTTPRequestOperationManager alloc] init];
    _requestManager.requestSerializer = requestSerializer;
    _requestManager.responseSerializer = responseSerializer;

    [_requestManager POST:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        NSDictionary *result = (NSDictionary *)responseObject;
        //        NSLog(@"result = %@",result);
        NSArray *resultArray = [result objectForKey:@"list"];
        for (NSDictionary *dic in resultArray) {
            [_dataArray addObject:[dic objectForKey:@"url"]];
            
        }
        [self.collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

- (void)initView
{
    self.view.backgroundColor = colorWithHexString(@"#b4dbcd");
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 64, kWinWidth - 20, 160)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    NSString *urlString = self.dataModel.stickerUrlString;
    if (![urlString isKindOfClass:[NSNull class]]) {
        NSURL *url = [NSURL URLWithString:urlString];
        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"sticker_pic"]];
    }
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64 + 160, kWinWidth, kWinHeight - 160 - 64 - 44 - 10 - 10) collectionViewLayout:layout];
    self.collectionView.backgroundColor = colorWithHexString(@"#b4dbcd");
    [self.collectionView registerClass:[ShopCollectionViewCell class] forCellWithReuseIdentifier:@"cellIde"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(10, kWinHeight  - 54, kWinWidth - 20, 44)];
    [self.view addSubview:_bottomView];
    
    //    _progressView = [[THProgressView alloc] initWithFrame:CGRectMake(0, 0, kWinWidth - 20, 44)];
    //    [_bottomView addSubview:_progressView];
    
    _asProgressView = [[ASProgressPopUpView alloc] initWithFrame:CGRectMake(0, 30, kWinWidth - 20, 20)];
    [_bottomView addSubview:_asProgressView];
    _asProgressView.hidden = YES;
    _asProgressView.delegate = self;
    _asProgressView.font = [UIFont systemFontOfSize:17];
    _asProgressView.popUpViewColor = colorWithHexString(@"#5cbc99");
    //    [_asProgressView showPopUpViewAnimated:YES];
    //    [_asProgressView hidePopUpViewAnimated:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadZip:)];
    _downloadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWinWidth - 20, 44)];
    _downloadView.userInteractionEnabled = YES;
    [_bottomView addSubview:_downloadView];
    _bottomView.backgroundColor = colorWithHexString(@"#5cbc99");
    [_downloadView addGestureRecognizer:tap];
    UIImageView *downloadIcon = [[UIImageView alloc] initWithFrame:CGRectMake((kWinWidth - 20) / 2 - 10, 14, 19, 19)];
    [_downloadView addSubview:downloadIcon];
    [downloadIcon setImage:[UIImage imageNamed:@"download.png"]];
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((kWinWidth - 20) /2, 0, 80, 44)];
    //    label.text = LocalizedString(@"main_download", nil);
    //    label.textAlignment = NSTextAlignmentLeft;
    //    label.font = [UIFont systemFontOfSize:17];
    //    label.textColor = [UIColor whiteColor];
    //    [_downloadView addSubview:label];
    self.completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.completeBtn setImage:[UIImage imageNamed:@"s_wancheng"] forState:UIControlStateNormal];
    [self.completeBtn addTarget:self action:@selector(complete:) forControlEvents:UIControlEventTouchUpInside];
    [self.completeBtn setFrame:CGRectMake(0, 0, kWinWidth - 20, 44)];
    [_bottomView addSubview:self.completeBtn];
    self.completeBtn.hidden = YES;
}

- (void)complete:(UIButton *)btn
{
//    for (UIViewController *vc in self.navigationController.viewControllers) {
//        if ([vc isKindOfClass:[ShopViewController class]] && self.type == kStickerShop) {
//            [self.navigationController popToViewController:vc animated:YES];
//        }
//        if ([vc isKindOfClass:[NC_MainViewController class]] && self.type == kBackgroundShop) {
//            [self.navigationController popToViewController:vc animated:YES];
//        }
//    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)progressViewDidHidePopUpView:(ASProgressPopUpView *)progressView
{
    _asProgressView.hidden = YES;
    self.completeBtn.hidden = NO;
    _bottomView.backgroundColor = colorWithHexString(@"#5cbc99");
}

- (void)progressViewWillDisplayPopUpView:(ASProgressPopUpView *)progressView
{
    
}

- (void)downloadZip:(UITapGestureRecognizer *)tap
{
    _asProgressView.hidden = NO;
    _bottomView.backgroundColor = [UIColor clearColor];
    [_asProgressView setProgress:0];
    [_asProgressView showPopUpViewAnimated:YES];
    tap.view.hidden = YES;
    NSString *basePath;
    if (self.type == kStickerShop) {
        basePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/Sticker"];
        
    }else if (self.type == kBackgroundShop){
        basePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/Background"];
    }
    //    NSString *path = [NSString stringWithFormat:@"%@%@",basePath,self.dataModel.stickerName];
    [self downloadFileURL:self.dataModel.stickerZipUrlString savePath:basePath fileName:self.dataModel.stickerMd5String tag:0];
}

/**
 * 下载文件
 */
- (void)downloadFileURL:(NSString *)aUrl savePath:(NSString *)aSavePath fileName:(NSString *)aFileName tag:(NSInteger)aTag
{
    _isDownload = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //检查本地文件是否已存在
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.zip", aSavePath, aFileName];
    NSLog(@"fileName = %@",fileName);
    NSLog(@"downloadUrl = %@",aUrl);
    self.finalFileName = fileName;
    //检查附件是否存在
    if ([fileManager fileExistsAtPath:fileName]) {
        [fileManager removeItemAtPath:fileName error:nil];
    }
    if ([fileManager fileExistsAtPath:aSavePath]) {
//        [fileManager removeItemAtPath:aSavePath error:nil];
    }else{
        [fileManager createDirectoryAtPath:aSavePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.filefo = [NSString stringWithFormat:@"%@/%@", aSavePath, self.dataModel.stickerMd5String];
    //        NSData *audioData = [NSData dataWithContentsOfFile:fileName];
    //    }else{
    //        //创建附件存储目录
    //        if (![fileManager fileExistsAtPath:aSavePath]) {
    //            [fileManager createDirectoryAtPath:aSavePath withIntermediateDirectories:YES attributes:nil error:nil];
    //
    //下载附件
    NSURL *url = [[NSURL alloc] initWithString:aUrl];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    __weak PreviewViewController *preview= self;

//    NSURLRequest*request=[[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:100.0];//设置缓存和超时
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    connection = nil;
    connection=[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];

//    _operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    _operation.shouldUseCredentialStorage = NO;
//    _operation.responseSerializer = [AFHTTPResponseSerializer serializer];
//    _operation.inputStream   = [NSInputStream inputStreamWithURL:url];
//
//    _operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:fileName append:YES];
//    //下载进度控制
//    [_operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        float progress = (float)totalBytesRead/totalBytesExpectedToRead;
//        NSLog(@"totalBytes = %lld",totalBytesExpectedToRead);
//        NSLog(@"is download：%f",progress);
//        //             [_progressView setProgress:progress animated:YES];
//        [preview.asProgressView setProgress:progress animated:YES];
//        if (progress == 1) {
//            preview.isDownload = NO;
////            [preview.asProgressView hidePopUpViewAnimated:YES];
//        }
//    }];
//    
//    __weak PreviewViewController *preVC = self;
//    //已完成下载
//    [_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"getMd5 = %@", [MD5Tools getFileMD5WithPath:fileName]);
//        NSLog(@"file.md5 = %@",preview.dataModel.stickerMd5String);
//        if (![[MD5Tools getFileMD5WithPath:fileName] isEqualToString:preview.dataModel.stickerMd5String] ) {
//            NSLog(@"downloadFaild");
////           BOOL ret =  [fileManager removeItemAtPath:fileName error:nil];
////            NSLog(@"ret = %d",ret);
//             [[[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"main_download_failed", nil) delegate:nil cancelButtonTitle:LocalizedString(@"main_confirm", nil) otherButtonTitles:nil, nil] show];
//            preview.asProgressView.hidden = YES;
//            preview.downloadView.hidden = NO;
//            preview.isDownload = NO;
//            preview.bottomView.backgroundColor = colorWithHexString(@"#5cbc99");
//            preVC.completeBtn.hidden = YES;
//            
//            return ;
//        }
//        [preview.asProgressView hidePopUpViewAnimated:YES];
//
//        NSLog(@"success");
        //检查本地文件是否已存在
//        NSString *fileFolder = [NSString stringWithFormat:@"%@/%@", aSavePath, preview.dataModel.stickerMd5String];
//        if (![fileManager fileExistsAtPath:fileFolder]) {
//            [fileManager createDirectoryAtPath:fileFolder withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//        ZipArchive *za = [[ZipArchive alloc] init];
//        if ([za UnzipOpenFile: fileName]) {
//            BOOL ret = [za UnzipFileTo: fileFolder overWrite: YES];
//            if (YES == ret){
//                NSLog(@"unZip Success");
//                BOOL res =  [fileManager removeItemAtPath:fileName error:nil];
//                if (res) {
//                    NSLog(@"delete File Success");
//                }
//                //                    NSFileManager * fm = [NSFileManager defaultManager];
//                //                     NSArray * filels = [fm contentsOfDirectoryAtPath:fileFolder error:nil];
//                NSLog(@"sid = %d , folderPath = %@",preview.dataModel.stickerId,fileFolder);
//                NSDate *date = [NSDate date];
//                long time = (long)[date timeIntervalSince1970];
//                if (preview.type == kStickerShop) {
//                    [[Sticker_SQLiteManager shareStance] updateStickerInfo:preview.dataModel.stickerId withDownloadDir:fileFolder andDownloadTime:time andType:@"sticker"];
//                    [[Sticker_SQLiteManager shareStance] updateSitckerInfo:preview.dataModel.stickerId withIsLooked:0 andType:@"sticker"];
//                }else if (preview.type == kBackgroundShop){
//                    [[Sticker_SQLiteManager shareStance] updateStickerInfo:preview.dataModel.stickerId withDownloadDir:fileFolder andDownloadTime:time andType:@"background"];
//                    [[Sticker_SQLiteManager shareStance] updateSitckerInfo:preview.dataModel.stickerId withIsLooked:0 andType:@"background"];
//                }
//            }
//            [za UnzipCloseFile];
//            
//        }else{
//            NSLog(@"UnzipFaild");
//            BOOL ret =  [fileManager removeItemAtPath:fileName error:nil];
//            NSLog(@"ret = %d",ret);
//            [[[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"main_download_failed", nil) delegate:nil cancelButtonTitle:LocalizedString(@"main_confirm", nil) otherButtonTitles:nil, nil] show];
//            preview.asProgressView.hidden = YES;
//            preview.downloadView.hidden = NO;
//            preview.isDownload = NO;
//            preview.bottomView.backgroundColor = colorWithHexString(@"#5cbc99");
//            preVC.completeBtn.hidden = YES;
//            
//            return ;
//
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"faild.code = %ld",(long)error.code);
//        if (error.code != -999) {
//            [[[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"main_download_failed", nil) delegate:nil cancelButtonTitle:LocalizedString(@"main_confirm", nil) otherButtonTitles:nil, nil] show];
//        }
//        preview.asProgressView.hidden = YES;
//        preview.downloadView.hidden = NO;
//        preview.isDownload = NO;
//        preview.bottomView.backgroundColor = colorWithHexString(@"#5cbc99");
//        //下载失败
//        //            [self requestFailed:aTag];
//    }];
//    
//    [_operation start];
    
}

#pragma mark -
#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"response");
    
    self.data= [[NSMutableData alloc]init];
    
    NSHTTPURLResponse*httpResponse=(NSHTTPURLResponse*)response;
    
    if(httpResponse&&[httpResponse respondsToSelector:@selector(allHeaderFields)]){
        
        NSDictionary*httpResponseHeaderFields=[httpResponse allHeaderFields];
        
        totalBytes = [[httpResponseHeaderFields objectForKey:@"Content-Length"]longLongValue];
        NSLog(@"totalBytes = %lld",totalBytes);
    }//获取文件文件的大小
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"faild");
//    if (error.code != -999) {
        [[[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"main_download_failed", nil) delegate:nil cancelButtonTitle:LocalizedString(@"main_confirm", nil) otherButtonTitles:nil, nil] show];
//    }
    self.asProgressView.hidden = YES;
    self.downloadView.hidden = NO;
    self.isDownload = NO;
    self.bottomView.backgroundColor = colorWithHexString(@"#5cbc99");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
    NSLog(@"data.length = %lu",(unsigned long)[_data length]);
    NSLog(@"totalBytes = %lld",totalBytes);
    NSUInteger currentData = [_data length];
    float progress = (CGFloat)((currentData / 1.0f)/(totalBytes / 1.0f));
    
    NSLog(@"is download：%lld",([_data length])/totalBytes);
    //             [_progressView setProgress:progress animated:YES];
    [self.asProgressView setProgress:progress animated:YES];
    if (progress == 1) {
        self.isDownload = NO;
        //            [preview.asProgressView hidePopUpViewAnimated:YES];
    }

}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection

{//完成时调用
    
    NSLog(@"Finish");
    
//    NSString*filePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)objectAtIndex:0]stringByAppendingPathComponent:@"android.mp4"];
    
    [_data writeToFile:self.finalFileName atomically:NO];//将数据写入Documents目录。
    
    NSLog(@"%@",self.finalFileName);

        NSLog(@"getMd5 = %@", [MD5Tools getFileMD5WithPath:self.finalFileName]);
        NSLog(@"file.md5 = %@",self.dataModel.stickerMd5String);
        if (![[MD5Tools getFileMD5WithPath:self.finalFileName] isEqualToString:self.dataModel.stickerMd5String] ) {
            NSLog(@"downloadFaild");
            //           BOOL ret =  [fileManager removeItemAtPath:fileName error:nil];
            //            NSLog(@"ret = %d",ret);
            [[[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"main_download_failed", nil) delegate:nil cancelButtonTitle:LocalizedString(@"main_confirm", nil) otherButtonTitles:nil, nil] show];
            self.asProgressView.hidden = YES;
            self.downloadView.hidden = NO;
            self.isDownload = NO;
            self.bottomView.backgroundColor = colorWithHexString(@"#5cbc99");
            self.completeBtn.hidden = YES;
            
            return ;
        }
        [self.asProgressView hidePopUpViewAnimated:YES];
        
        NSLog(@"success");
        //检查本地文件是否已存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString *fileFolder = [NSString stringWithFormat:@"%@/%@", aSavePath, preview.dataModel.stickerMd5String];
//        if (![fileManager fileExistsAtPath:fileFolder]) {
//            [fileManager createDirectoryAtPath:fileFolder withIntermediateDirectories:YES attributes:nil error:nil];
//        }
        ZipArchive *za = [[ZipArchive alloc] init];
        if ([za UnzipOpenFile: self.finalFileName]) {
            BOOL ret = [za UnzipFileTo: self.filefo overWrite: YES];
            if (YES == ret){
                NSLog(@"unZip Success");
                BOOL res =  [fileManager removeItemAtPath:self.finalFileName error:nil];
                if (res) {
                    NSLog(@"delete File Success");
                }
                //                    NSFileManager * fm = [NSFileManager defaultManager];
                //                     NSArray * filels = [fm contentsOfDirectoryAtPath:fileFolder error:nil];
                NSLog(@"sid = %d , folderPath = %@",self.dataModel.stickerId,self.filefo);
                NSDate *date = [NSDate date];
                long time = (long)[date timeIntervalSince1970];
                if (self.type == kStickerShop) {
                    [[Sticker_SQLiteManager shareStance] updateStickerInfo:self.dataModel.stickerId withDownloadDir:self.filefo andDownloadTime:time andType:@"sticker"];
                    [[Sticker_SQLiteManager shareStance] updateSitckerInfo:self.dataModel.stickerId withIsLooked:0 andType:@"sticker"];
                }else if (self.type == kBackgroundShop){
                    [[Sticker_SQLiteManager shareStance] updateStickerInfo:self.dataModel.stickerId withDownloadDir:self.filefo andDownloadTime:time andType:@"background"];
                    [[Sticker_SQLiteManager shareStance] updateSitckerInfo:self.dataModel.stickerId withIsLooked:0 andType:@"background"];
                }
            }
            [za UnzipCloseFile];
            
        }else{
            NSLog(@"UnzipFaild");
            BOOL ret =  [fileManager removeItemAtPath:self.finalFileName error:nil];
            NSLog(@"ret = %d",ret);
            [[[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"main_download_failed", nil) delegate:nil cancelButtonTitle:LocalizedString(@"main_confirm", nil) otherButtonTitles:nil, nil] show];
            self.asProgressView.hidden = YES;
            self.downloadView.hidden = NO;
            self.isDownload = NO;
            self.bottomView.backgroundColor = colorWithHexString(@"#5cbc99");
            self.completeBtn.hidden = YES;
            
            return ;
            
        }
    
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIde" forIndexPath:indexPath];
    NSString *urlString = [_dataArray objectAtIndex:indexPath.row];
    if (![urlString isKindOfClass:[NSNull class]]) {
        NSURL *url = [NSURL URLWithString:urlString];
        [cell.imageview sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"sticker_holder"]];
        cell.imageview.contentMode = UIViewContentModeScaleAspectFit;
    }
    //    [cell.imageview sd_setImageWithURL:_currentSticker.urlArray[indexPath.row] placeholderImage:[UIImage imageNamed:@"icon"] options:0];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

#pragma mark -
#pragma mark - UICollectionFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kWinWidth / 4 -1, kWinWidth / 4 - 1);
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
