//
//  AppDelegate.m
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/3/24.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "AppDelegate.h"
#import "PS_TabBarViewController.h"
#import "PS_DiscoverViewController.h"
#import "PS_HotViewController.h"
#import "PS_NotificationViewController.h"
#import "PS_AchievementViewController.h"
#import "PS_BaseNavigationController.h"
#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "PS_StoreViewController.h"
#import "Sticker_DataUtil.h"
#import "StickerDataModel.h"
#import "Sticker_SQLiteManager.h"
@interface AppDelegate ()
{
    AFHTTPRequestOperationManager *_requestManager;
}
@property (nonatomic, assign) PS_ShopType type;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PS_DiscoverViewController *findVC = [[PS_DiscoverViewController alloc] init];
    PS_HotViewController *hotVC = [[PS_HotViewController alloc] init];
    PS_NotificationViewController *notificationVC = [[PS_NotificationViewController alloc] init];
    PS_AchievementViewController *achievementVC = [[PS_AchievementViewController alloc] init];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin] == YES) {
        achievementVC.uid = [[NSUserDefaults standardUserDefaults] objectForKey:kUid];
        achievementVC.userImage = [[NSUserDefaults standardUserDefaults] objectForKey:kPic];
        achievementVC.userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
    }
    PS_BaseNavigationController *findNC = [[PS_BaseNavigationController alloc] initWithRootViewController:findVC];
    PS_BaseNavigationController *hotNC = [[PS_BaseNavigationController alloc] initWithRootViewController:hotVC];
    PS_BaseNavigationController *notificationNC = [[PS_BaseNavigationController alloc] initWithRootViewController:notificationVC];
    PS_BaseNavigationController *achievementNC = [[PS_BaseNavigationController alloc] initWithRootViewController:achievementVC];

    PS_TabBarViewController *tabBarVC = [[PS_TabBarViewController alloc] init];
    tabBarVC.viewControllers = @[findNC,hotNC,notificationNC,achievementNC];
    
//    ViewController *vc = [[ViewController alloc] init];
//    self.window.rootViewController = vc;
//    [self doRequestShopDataWithType:kPSStickerShop];
//        [self doRequestShopDataWithType:kPSBackgroundShop];
    self.window.rootViewController = tabBarVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)doRequestShopDataWithType:(PS_ShopType)type
{
    NSDate *lastDate = nil;
    if (type == kPSStickerShop) {
        lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestPhotoMarkTime"];
    }else if (type == kPSBackgroundShop){
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
        if (type == kPSStickerShop) {
            dic = [[NSDictionary alloc]initWithObjectsAndKeys:language,@"lang",@20051,@"appId",@0,@"plat",@0,@"type",nil];
        }
        else if (type == kPSBackgroundShop)
        {
            dic = [[NSDictionary alloc]initWithObjectsAndKeys:language,@"lang",@20051,@"appId",@0,@"plat",@1,@"type",nil];
        }
        //请求数据
        
//        if (![self checkNetWorking]){
//            return ;
//        }
        
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
            NSNumber *number = nil;
            if (type == kPSStickerShop) {
                number = [[NSUserDefaults standardUserDefaults] objectForKey:kStickerMaxSid];
                if (number == nil) {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:HAVE_NEW_STICKER];
                    [[NSNotificationCenter defaultCenter] postNotificationName:HAVE_NEW_STICKER object:[NSDate date]];
                    //                [self setSpot];
                }
                
            }else{
                number = [[NSUserDefaults standardUserDefaults] objectForKey:kBackgroundMaxSid];
                if (number == nil) {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:HAVE_NEW_BACKGROUND];
                    [[NSNotificationCenter defaultCenter] postNotificationName:HAVE_NEW_BACKGROUND object:[NSDate date]];
                    //                [self setSpot];
                }

            }
            for (NSDictionary *dic in resultArray) {
                StickerDataModel *dataModel = [[StickerDataModel alloc] init];
                dataModel.stickerId = ((NSNumber *)[dic objectForKey:@"id"]).intValue;
                if (number != nil) {
                    if (dataModel.stickerId > number.intValue) {
                        if (type == kPSStickerShop) {
                            
                        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:HAVE_NEW_STICKER];
                        [[NSNotificationCenter defaultCenter] postNotificationName:HAVE_NEW_STICKER object:[NSDate date]];
//                        [self setSpot];
                        }else{
                            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:HAVE_NEW_BACKGROUND];
                            [[NSNotificationCenter defaultCenter] postNotificationName:HAVE_NEW_BACKGROUND object:[NSDate date]];
                        }
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
            if (type == kPSStickerShop) {
                [sqliteManager deleteAllDataForStickerWithType:@"sticker"];
                [sqliteManager insertChatList:dataArray photoMarkType:@"sticker"];
            }else if (type == kPSBackgroundShop){
                [sqliteManager deleteAllDataForStickerWithType:@"background"];
                [sqliteManager insertChatList:dataArray photoMarkType:@"background"];
            }
            for (StickerDataModel *model in tempArray) {
                if (model.localDir.length > 2) {
                    if (type == kPSStickerShop) {
                        [sqliteManager updateSitckerInfo:model.stickerId withIsLooked:model.stickerIsLooked andType:@"sticker"];
                        [sqliteManager updateStickerInfo:model.stickerId withDownloadDir:model.localDir andDownloadTime:model.stickerDownloadTime andType:@"sticker"];
                    }else if (type == kPSBackgroundShop){
                        [sqliteManager updateSitckerInfo:model.stickerId withIsLooked:model.stickerIsLooked andType:@"background"];
                        [sqliteManager updateStickerInfo:model.stickerId withDownloadDir:model.localDir andDownloadTime:model.stickerDownloadTime andType:@"background"];
                    }
                }
            }
            //         NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestPhotoMarkTime"];
            if (type == kPSStickerShop) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"requestPhotoMarkTime"];
            }else if (type == kPSBackgroundShop){
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"requestBackgroundTime"];
            }
            if (type == kPSStickerShop) {
//                [self doRequestShopDataWithType:kPSBackgroundShop];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (type == kPSStickerShop) {
//                [self doRequestShopDataWithType:kPSBackgroundShop];
            }

        }];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
