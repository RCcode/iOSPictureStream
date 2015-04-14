//
//  PRJ_SQLiteMassager.h
//  IOSNoCrop
//
//  Created by gaoluyangrc on 14-4-24.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class PRJ_PhotoMarkObject;
@class FONT_fontTypeObject;

#define kPhotoMarkFileName  @"NearlyPhotoMarks.sql"
#define kTypeFaceFileName @"TypeFace.sql"
#define kColorMatrixFileName @"ColorMatrix.sql"
#define kAppsInfoFileName @"AppsInfo.sql"
#define kStickerInfoFileName @"StickerInfo.sql"

typedef enum StickerSqliteType
{
    StickerType
}StickerSqliteType;

@interface PS_SQLiteManager : NSObject
{
    sqlite3 *_database;
    BOOL _isMoreApp;
}

@property (nonatomic ,assign) sqlite3 *_database;
@property (nonatomic ,assign) enum StickerSqliteType tableType;

+ (PS_SQLiteManager *)shareStance;

////会话列表
//- (NSString *)dataFilePath;
////创建数据库
//- (BOOL)createTable:(sqlite3 *)db;
//
////创建数据库
//- (BOOL)createAppsInfoTable:(sqlite3 *)db;
//
//插入数据
- (BOOL)insertChatList:(NSArray *)photoMarkArray photoMarkType:(NSString *)type;
//- (BOOL)insertTypeFace:(FONT_fontTypeObject *)typeFaceObject;
//获取全部数据
- (NSMutableArray*)getStickerDataWithType:(NSString *)type;
//- (NSMutableArray *)getAllTypeFaces;
////删除数据：
//- (BOOL)deleteChatList:(PRJ_PhotoMarkObject *)photoMark;
//- (BOOL)deleteTypeFace:(FONT_fontTypeObject *)typeFaceObject;
////查询数据库，searchID为要查询数据的ID，返回数据为查询到的数据
//- (NSMutableArray *)searchTestList:(NSString *)type;
////查询最大ID
//- (NSInteger)selectMaxId;
//- (BOOL)deleteAllDataForMarkType:(NSString *)markType;
//
//- (BOOL)insertAppInfo:(NSMutableArray *)appsInfo;

//- (NSMutableArray *)getAllAppsInfoData;
- (BOOL)updateStickerInfo:(int)sid withDownloadDir:(NSString *)dir andDownloadTime:(long)time andType:(NSString *)type;

- (BOOL)updateSitckerInfo:(int)sid withIsLooked:(int)isLooked andType:(NSString *)type;

- (BOOL)deleteAllDataForStickerWithType:(NSString *)type;

@end
