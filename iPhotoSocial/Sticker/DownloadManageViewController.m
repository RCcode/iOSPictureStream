//
//  DownloadManageViewController.m
//  StickerAndBackgroundShop
//
//  Created by MAXToooNG on 14/12/3.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "DownloadManageViewController.h"
#import "Sticker_SQLiteManager.h"
#import "StickerDataModel.h"
#import "DownloadManageCell.h"
#import "UIImageView+WebCache.h"

#define kWinWidth [UIScreen mainScreen].bounds.size.width
#define kWinHeight [UIScreen mainScreen].bounds.size.height
@interface DownloadManageViewController ()
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    NSInteger _currentIndex;
}
@end

@implementation DownloadManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = left;
}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initData
{
    _dataArray = [[NSMutableArray alloc] init];
    if (self.type == kStickerShop) {
        
        if ([[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"sticker"].count == 0) {
        }else{
            NSArray *array = [[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"sticker"];
            for (StickerDataModel *model in array) {
                if (model.stickerDownloadTime > 0 && model.localDir.length > 2) {
                    [_dataArray addObject:model];
                    
                }else{
                }
            }
            
            [_tableView reloadData];
            if (_dataArray.count == 0) {
                UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"无贴纸"]];
                imageview.frame = CGRectMake(0, 0, 84, 84);
                imageview.center = self.view.center;
                [self.view addSubview:imageview];
            }
        }
    }else if (self.type == kBackgroundShop){
        if ([[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"background"].count == 0) {
        }else{
            NSArray *array = [[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"background"];
            for (StickerDataModel *model in array) {
                if (model.stickerDownloadTime > 0 && model.localDir.length > 2) {
                    [_dataArray addObject:model];
                    
                }else{
                }
            }
            
            [_tableView reloadData];
            if (_dataArray.count == 0) {
                UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"无贴纸"]];
                imageview.frame = CGRectMake(0, 0, 84, 84);
                imageview.center = self.view.center;
                [self.view addSubview:imageview];
            }
        }
    }
    
}

- (void)initView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWinWidth, kWinHeight)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIde = @"cellIde";
    DownloadManageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell = [[DownloadManageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setDeleteButtonTarget:self andSelector:@selector(deleteCurrentCell:)];
    StickerDataModel *model = [_dataArray objectAtIndex:indexPath.row];
    NSString *urlString = model.stickerUrlString;
    NSLog(@"urlString = %@",urlString);
    if (![urlString isKindOfClass:[NSNull class]]) {
        NSURL *url = [NSURL URLWithString:urlString];
        [cell.bannerView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"sticker_pic"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }
    return cell;
    
}

- (void)deleteCurrentCell:(UIButton *)btn
{
    DownloadManageCell *cell = nil;
    if (IOS7()) {
        cell = (DownloadManageCell *)[[[[btn superview] superview] superview] superview];
    }
    if (IOS8()) {
        cell = (DownloadManageCell *)[[[btn superview] superview] superview];
    }

    _currentIndex = [_tableView indexPathForCell:cell].row;
    NSLog(@"_currentIndex = %ld",_currentIndex);
    [[[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"main_delete", nil) delegate:self cancelButtonTitle:LocalizedString(@"main_cancel", nil) otherButtonTitles:LocalizedString(@"main_confirm", nil), nil] show];
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForCell:cell] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 145;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    DownloadManageCell *cell = (DownloadManageCell *)[tableView cellForRowAtIndexPath:indexPath];
//    cell.deleteView.backgroundColor = colorWithHexString(@"#5cbc99");
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"cancel");
        }
            break;
        case 1:
        {
            StickerDataModel *model = _dataArray[_currentIndex];
            NSString *folderPath;
            if (self.type == kStickerShop) {
                [[Sticker_SQLiteManager shareStance] updateStickerInfo:model.stickerId withDownloadDir:@" " andDownloadTime:0 andType:@"sticker"];
                folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Sticker"];
            }else if (self.type == kBackgroundShop){
                [[Sticker_SQLiteManager shareStance] updateStickerInfo:model.stickerId withDownloadDir:@" " andDownloadTime:0 andType:@"background"];
                folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Background"];
            }
            NSString *md5 = model.stickerMd5String;
            folderPath = [NSString stringWithFormat:@"%@/%@",folderPath,md5];
            NSLog(@"folderPath = %@",folderPath);
            NSFileManager * fm = [NSFileManager defaultManager];
            BOOL ret = [fm removeItemAtPath:folderPath error:nil];
            if (ret) {
                NSLog(@"deleteSuccess");
                [self reloadTableView];
            }
            NSLog(@"confirm");
        }
        default:
            break;
    }
}

- (void)reloadTableView
{
    [_dataArray removeAllObjects];
    if (self.type == kStickerShop) {
        
        if ([[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"sticker"].count == 0) {
        }else{
            NSArray *array = [[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"sticker"];
            for (StickerDataModel *model in array) {
                if (model.stickerDownloadTime > 0 && model.localDir.length > 2) {
                    [_dataArray addObject:model];
                    
                }else{
                }
            }
            
            [_tableView reloadData];
            if (_dataArray.count == 0) {
                UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"无贴纸"]];
                imageview.frame = CGRectMake(0, 0, 84, 84);
                imageview.center = self.view.center;
                [self.view addSubview:imageview];
            }
            
        }
    }else if (self.type == kBackgroundShop){
        if ([[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"background"].count == 0) {
        }else{
            NSArray *array = [[Sticker_SQLiteManager shareStance] getStickerDataWithType:@"background"];
            for (StickerDataModel *model in array) {
                if (model.stickerDownloadTime > 0 && model.localDir.length > 2) {
                    [_dataArray addObject:model];
                    
                }else{
                }
            }
            
            [_tableView reloadData];
            if (_dataArray.count == 0) {
                UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"无贴纸"]];
                imageview.frame = CGRectMake(0, 0, 84, 84);
                imageview.center = self.view.center;
                [self.view addSubview:imageview];
            }
            
        }
    }
    
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
