//
//  BloomView.m
//  YRUK
//
//  Created by lisongrc on 15-4-8.
//  Copyright (c) 2015年 rcplatform. All rights reserved.
//

#import "PS_BloomView.h"

#define kZoomInTime 0.8
#define kZoomOutTime 0.2
#define kTotalTime 0.3

@interface PS_BloomView ()

@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) UIButton *centerBtn;

@property (nonatomic, assign) CGSize cenBtnSize;
@property (nonatomic, assign) CGSize startSize;
@property (nonatomic, assign) CGSize middleSize;
@property (nonatomic, assign) CGSize endSize;

@property (nonatomic, assign) CGFloat startRadius;
@property (nonatomic, assign) CGFloat middleRadius;
@property (nonatomic, assign) CGFloat endRadius;

@property (nonatomic, assign,getter=isBloom) BOOL bloom;

@end

@implementation PS_BloomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _btnArray = [[NSMutableArray alloc] initWithCapacity:1];
        for (int i = 0; i<5; i++) {
            self.clipsToBounds = YES;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor greenColor];
            button.frame = CGRectMake(0, 0, 20, 20);
            button.center = CGPointMake(32, 32);
            button.tag = i;
            [self addSubview:button];
            [_btnArray addObject:button];
            
            if (i == 0 || i == 4) {
                button.hidden = YES;
            }
        }
        
        _centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerBtn.frame = CGRectMake(0, 0, 20, 20);
        _centerBtn.center = CGPointMake(32, 32);
        [_centerBtn addTarget:self action:@selector(centerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _centerBtn.backgroundColor = [UIColor orangeColor];
        [self addSubview:_centerBtn];
        
        _startSize = frame.size;
        _endSize  = CGSizeMake(288, 288);
        _middleSize = CGSizeMake(350, 350);
        
        _startRadius = 32;
        _endRadius = 144;
        _middleRadius = 175;
    }
    return self;
}

- (void)centerButtonClick:(UIButton *)btn{
    self.isBloom?[self cancelAnimation]:[self bloomAnimation];
}

- (void)bloomAnimation{
    _bloom = YES;
    //自己
    CAKeyframeAnimation *basic = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    basic.values = @[[NSValue valueWithCGRect:CGRectMake(0, 0, _startSize.width, _startSize.height)],
                     [NSValue valueWithCGRect:CGRectMake(0, 0, _middleSize.width, _middleSize.height)],
                     [NSValue valueWithCGRect:CGRectMake(0, 0, _endSize.width, _endSize.height)],
                     ];
    basic.duration = kTotalTime;
    basic.keyTimes = @[@0,@kZoomInTime,@1];
    [self.layer addAnimation:basic forKey:nil];
    
    CAKeyframeAnimation *basic1 = [CAKeyframeAnimation animationWithKeyPath:@"cornerRadius"];
    basic1.values = @[[NSNumber numberWithFloat:_startRadius],
                      [NSNumber numberWithFloat:_middleRadius],
                      [NSNumber numberWithFloat:_endRadius]];
    basic1.duration = kTotalTime;
    basic1.keyTimes = @[@0,@kZoomInTime,@1];
    [self.layer addAnimation:basic1 forKey:nil];
    
    self.layer.bounds = CGRectMake(0, 0, _endSize.width, _endSize.height);
    self.layer.cornerRadius = _endRadius;
    
    //按钮
    for (UIButton *btn in _btnArray) {
        CAKeyframeAnimation *basic = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        basic.values = @[[NSValue valueWithCGPoint:CGPointMake(_startRadius, _startRadius)],
                         [NSValue valueWithCGPoint:[self createEndPointWithRadius:_middleRadius andAngel:
                                                    (45.0*btn.tag)/180.0]],
                         [NSValue valueWithCGPoint:[self createEndPointWithRadius:_endRadius andAngel:
                                                    (45.0*btn.tag)/180.0]]];
        basic.keyTimes = @[@0,@kZoomInTime,@1];
        basic.duration = kTotalTime;
        [btn.layer addAnimation:basic forKey:nil];
        btn.layer.position = [self createEndPointWithRadius:_endRadius andAngel:
                                                        (45.0*btn.tag)/180.0];
    }
    
    
    //中间button
    CAKeyframeAnimation *basic2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    basic2.values = @[[NSValue valueWithCGPoint:CGPointMake(_startRadius, _startRadius)],
                      [NSValue valueWithCGPoint:CGPointMake(_middleRadius, _middleRadius)],
                      [NSValue valueWithCGPoint:CGPointMake(_endRadius, _endRadius)]];
    basic2.keyTimes = @[@0,@kZoomInTime,@1];
    basic2.duration = kTotalTime;
    [_centerBtn.layer addAnimation:basic2 forKey:nil];
    _centerBtn.layer.position = CGPointMake(_endRadius, _endRadius);
}

- (void)cancelAnimation{
    _bloom = NO;
    
    //自己
    CAKeyframeAnimation *basic = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    basic.values = @[[NSValue valueWithCGRect:CGRectMake(0, 0, _endSize.width, _endSize.height)],
                     [NSValue valueWithCGRect:CGRectMake(0, 0, _middleSize.width, _middleSize.height)],
                     [NSValue valueWithCGRect:CGRectMake(0, 0, _startSize.width, _startSize.height)]];
    basic.duration = kTotalTime;
    basic.keyTimes = @[@0,@kZoomOutTime,@1.0];
    [self.layer addAnimation:basic forKey:nil];
    
    
    CAKeyframeAnimation *basic1 = [CAKeyframeAnimation animationWithKeyPath:@"cornerRadius"];
    basic1.values = @[[NSNumber numberWithFloat:_endRadius],
                      [NSNumber numberWithFloat:_middleRadius],
                      [NSNumber numberWithFloat:_startRadius]];
    basic1.duration = kTotalTime;
    basic1.keyTimes = @[@0,@kZoomOutTime,@1.0];
    [self.layer addAnimation:basic1 forKey:nil];
    
    self.layer.bounds = CGRectMake(0, 0, _startSize.width, _startSize.width);
    self.layer.cornerRadius = _startRadius;
    
    //按钮
    for (UIButton *btn in _btnArray) {
        CAKeyframeAnimation *basic = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        basic.values = @[[NSValue valueWithCGPoint:[self createEndPointWithRadius:_endRadius andAngel:
                                                    (45.0*btn.tag)/180.0]],
                         [NSValue valueWithCGPoint:[self createEndPointWithRadius:_middleRadius andAngel:
                                                    (45.0*btn.tag)/180.0]],
                         [NSValue valueWithCGPoint:CGPointMake(_startRadius, _startRadius)]];
        
        basic.keyTimes = @[@0,@kZoomOutTime,@1.0];
        basic.duration = kTotalTime;
        [btn.layer addAnimation:basic forKey:nil];
        btn.layer.position = CGPointMake(_startRadius, _startRadius);
    }
    
    //中间button
    CAKeyframeAnimation *basic2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    basic2.values = @[[NSValue valueWithCGPoint:CGPointMake(_endRadius, _endRadius)],
                      [NSValue valueWithCGPoint:CGPointMake(_middleRadius, _middleRadius)],
                      [NSValue valueWithCGPoint:CGPointMake(_startRadius, _startRadius)]];
    basic2.keyTimes = @[@0,@kZoomOutTime,@1.0];
    basic2.duration = kTotalTime;
    [_centerBtn.layer addAnimation:basic2 forKey:nil];
    _centerBtn.layer.position = CGPointMake(_startRadius, _startRadius);
}

- (CGPoint)createEndPointWithRadius:(CGFloat)itemExpandRadius andAngel:(CGFloat)angel
{
    return CGPointMake(itemExpandRadius - cosf(angel * M_PI) * itemExpandRadius,
                       itemExpandRadius - sinf(angel * M_PI) * itemExpandRadius);
}

- (void)buttonClick:(UIButton *)btn{
    
    switch (btn.tag) {
        case 1:
            if ([_delegate respondsToSelector:@selector(imageBtnOnClick)]) {
                [_delegate imageBtnOnClick];
            }
            break;
        case 2:
            if ([_delegate respondsToSelector:@selector(videoBtnOnClick)]) {
                [_delegate videoBtnOnClick];
            }
            break;
        case 3:
            if ([_delegate respondsToSelector:@selector(shopBtnOnClick)]) {
                [_delegate shopBtnOnClick];
            }
            break;
        default:
            break;
    }
}

@end
