//
//  PS_AchievementViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_AchievementViewController.h"
#import "PS_ImageCollectionViewCell.h"
#import "PS_ImageDetailViewController.h"
#import "PS_SettingViewController.h"

#define kTopViewHeight 100

@interface PS_AchievementViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation PS_AchievementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"setting" style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonOnClick:)];
    self.navigationItem.rightBarButtonItem = leftButtonItem;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kTopViewHeight)];
    view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:view];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    UICollectionView *collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kTopViewHeight, kWindowWidth, kEditFrameHeight - kTopViewHeight) collectionViewLayout:layout];
    collect.backgroundColor = [UIColor redColor];
    collect.dataSource = self;
    collect.delegate = self;
    [self.view addSubview:collect];
    
    [collect registerClass:[PS_ImageCollectionViewCell class] forCellWithReuseIdentifier:@"Achievement"];
}

- (void)settingButtonOnClick:(UIBarButtonItem *)barButton
{
    PS_SettingViewController *settingVC = [[PS_SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
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
    PS_ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Achievement" forIndexPath:indexPath];
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

@end
