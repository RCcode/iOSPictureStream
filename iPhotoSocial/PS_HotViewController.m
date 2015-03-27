//
//  PS_HotViewController.m
//  iPhotoSocial
//
//  Created by gaoluyangrc on 15-3-25.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_HotViewController.h"
#import "PS_ImageDetailViewCell.h"
#import "TestModel.h"

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
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PS_ImageDetailViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"imageDetail"];
    self.tableView.delaysContentTouches = NO;
    
    
    TestModel *model = [[TestModel alloc] init];
    model.type = 1;
    model.desc = @"a";
    TestModel *model1 = [[TestModel alloc] init];
    model1.type = 2;
    model1.desc = @"sdhjshdfhjsdbjsbfjdsfjdsfsdfsdfdsfsdddddddddsdhjshdfhjsdbjsbfjdsfjdsfsdfsdfdsfsdddddddddsdhjshdfhjsdbjsbfjdsfjdsfsdfsdfdsfsdddddddddsdhjshdfhjsdbjsbfjdsfjdsfsdfsdfdsfsdddddddddsdhjshdfhjsdbjsbfjdsfjdsfsdfsdfdsfsddddddddd";

    TestModel *model2 = [[TestModel alloc] init];
    model2.type = 2;
    model2.desc = @"的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v";

    TestModel *model3 = [[TestModel alloc] init];
    model3.type = 2;
    model3.desc = @"的烧烤的积分开始的你发给你们重新女性从V型从V型从V型从v";
    
    self.array = @[model,model1,model2,model3];
}

//判断应该播放那个视频
static PS_ImageDetailViewCell *lastCell;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *array = [self.tableView visibleCells];
    for (PS_ImageDetailViewCell *cell in array) {
        CGPoint point = [self.tableView convertPoint:cell.center toView:self.view];
        if (CGRectContainsPoint(self.tableView.frame, point)) {
            if ([cell.mp playbackState] == MPMoviePlaybackStatePlaying) {
                continue;
            }else{
                if (cell.mp.contentURL != nil) {
                    [cell.mp play];
                    //                    lastCell = cell;
                    NSLog(@"play------------------");
                }
            }
        }else{
            if (cell.mp.playbackState == MPMoviePlaybackStatePlaying) {
                [cell.mp pause];
                NSLog(@"pause------------------");
            }
        }
    }
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 400;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PS_ImageDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageDetail" forIndexPath:indexPath];
    
    TestModel *model = self.array[indexPath.row];
    cell.model = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
