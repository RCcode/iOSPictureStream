//
//  PS_ImageDetailViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_ImageDetailViewController.h"
#import "PS_ImageDetailViewCell.h"

@interface PS_ImageDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation PS_ImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Photo";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.delaysContentTouches = NO;
    _tableView.sectionHeaderHeight = 64;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 460;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"PS_ImageDetailViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"imageDetail"];
    
    BOOL isLogin = NO;
    CGFloat loginViewHeight = isLogin?0:50;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, loginViewHeight)];
    [button setTitle:@"login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor greenColor];
    [self.view addSubview:button];

}

- (void)login:(UIButton *)button
{
    
}

#pragma mark -- UITableViewDelegate  UITableViewDataSource--
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageDetail" forIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
