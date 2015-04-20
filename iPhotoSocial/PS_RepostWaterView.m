//
//  PS_RepostWaterView.m
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/4/17.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_RepostWaterView.h"

@interface PS_RepostWaterView ()

@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *userName;
@end

@implementation PS_RepostWaterView

- (instancetype)initWithHeadUrlString:(NSString *)urlString oriName:(NSString *)userName andCenter:(CGPoint )center andStyle:(RepostWaterStyle)style
{
    self = [super initWithFrame:CGRectMake(0, 0, kWindowWidth, 30)];
    if (self ) {
        self.center = center;
        self.urlString = urlString;
        self.userName = userName;
        [self setFrameWithStyle:style];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
    return self;
}

- (void)setFrameWithStyle:(RepostWaterStyle)style
{
    
    if (style == kRepostTop || style == kRepostBottom) {
        self.bounds = CGRectMake(0, 0, kWindowWidth, 30);
        self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(8 + 23+ 4, 4, 250, 22)];
        self.headerView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 23, 23)];
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(windowWidth() - 8 - 21, 4, 21, 21)];
    }
    
    if (style == kRepostLeft || style == kRepostRight) {
        self.bounds = CGRectMake(0, 0, 30, kWindowWidth);
        self.headerView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 8, 23, 23)];
//        self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 8 + 23+ 4, 22, 200)];
         self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 250, 22)];
        self.userLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.userLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
//        self.userLabel.layer.anchorPoint = CGPointMake(0, 0);
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(4, windowWidth() - 8 - 21, 21, 21)];
    }
    [self addSubview:self.iconView];
    [self addSubview:self.headerView];
    [self addSubview: self.userLabel];
    [self.headerView sd_setImageWithURL:[NSURL URLWithString:self.urlString]];
    self.userLabel.text = [NSString stringWithFormat:@"@ %@",self.userName];
    self.userLabel.textColor = [UIColor whiteColor];
    self.userLabel.font = [UIFont systemFontOfSize:14];
    self.iconView.image = [UIImage imageNamed:@"ic_nocropicon"];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
