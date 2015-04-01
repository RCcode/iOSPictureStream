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
#import "PS_MediaModel.h"

@interface PS_HotViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *array;

@end

@implementation PS_HotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BOOL isLogin = NO;
    CGFloat loginViewHeight = isLogin?0:50;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, loginViewHeight)];
    [button setTitle:@"login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor greenColor];
    [self.view addSubview:button];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, loginViewHeight, kWindowWidth, kEditFrameHeight - loginViewHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 460;
    self.tableView.delaysContentTouches = NO;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PS_ImageDetailViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"imageDetail"];
    
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
    NSArray *array = [self.tableView visibleCells];
    
    for (PS_ImageDetailViewCell *cell in array) {
        CGPoint point = [self.tableView convertPoint:cell.center toView:self.view];
        
        if (CGRectContainsPoint(self.tableView.frame, point)) {
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
