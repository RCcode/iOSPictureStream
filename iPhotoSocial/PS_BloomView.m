//
//  BloomView.m
//  YRUK
//
//  Created by lisongrc on 15-4-8.
//  Copyright (c) 2015年 rcplatform. All rights reserved.
//

#import "PS_BloomView.h"

#define kZoomInTime 0.7
#define kZoomOutTime 0.3
#define kTotalTime 0.2

#define kLableHeight 14

@interface PS_BloomView ()

@property (nonatomic, strong) UIButton *centerBtn;
@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, strong) NSArray *angelArray;

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
        _viewArray = [[NSMutableArray alloc] initWithCapacity:1];
        self.clipsToBounds = YES;
        NSArray *images = @[@"store",@"store",@"edit_imgae",@"edit_video",@"edit_video"];
        NSArray *text = @[@"ps_set_store",@"ps_set_store",@"root_photos",@"root_videos",@"root_videos"];

        for (int i = 0; i<5; i++) {
//            //第一个按钮和最后一个没用到
//            NSArray *images = @[@"",@"store",@"edit_imgae",@"edit_video",@""];
//            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//            [button setBackgroundImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
//            button.frame = CGRectMake(0, 0, 49, 49);
//            button.center = CGPointMake(frame.size.width/2, frame.size.height/2);
//            button.layer.cornerRadius = 49/2.0;
//            button.tag = i;
//            [self addSubview:button];
//            [_btnArray addObject:button];
//            
//            if (i == 0 || i == 4) {
//                button.hidden = YES;
//            }
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 49, 70)];
            view.backgroundColor = [UIColor clearColor];
            view.center = CGPointMake(frame.size.width/2, frame.size.height/2);
            view.tag = i;
            [_viewArray addObject:view];
            [self addSubview:view];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
            button.frame = CGRectMake(0, 0, 49, 49);
            button.tag = i;
            [view addSubview:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 16, 49, 16)];
            label.backgroundColor = [UIColor clearColor];
            label.text = LocalizedString(text[i], nil);
            label.font = [UIFont systemFontOfSize:15];
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.5;
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            if (i == 0 || i == 4) {
                view.hidden = YES;
            }
        }
        
        _centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerBtn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _centerBtn.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [_centerBtn setImage:[UIImage imageNamed:@"jia"] forState:UIControlStateNormal];
        [_centerBtn addTarget:self action:@selector(centerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_centerBtn];
        
        _startSize = frame.size;
        _endSize  = CGSizeMake(288*kWindowWidth/320, 288*kWindowWidth/320);
        _middleSize = CGSizeMake(320*kWindowWidth/320, 320*kWindowWidth/320);
        
        _startRadius = frame.size.width/2;
        _endRadius = 144*kWindowWidth/320;
        _middleRadius = 160*kWindowWidth/320;
        
        _angelArray = @[@0.0,@20.0,@90.0,@160.0,@180.0];
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
    for (UIView *btn in _viewArray) {
        CAKeyframeAnimation *basic = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        basic.values = @[[NSValue valueWithCGPoint:CGPointMake(_startRadius, _startRadius)],
                         [NSValue valueWithCGPoint:[self createEndPointWithRadius:_middleRadius andAngel:
                                                    [_angelArray[btn.tag] doubleValue]/180.0]],
                         [NSValue valueWithCGPoint:[self createEndPointWithRadius:_endRadius andAngel:
                                                    [_angelArray[btn.tag] doubleValue]/180.0]]];
        basic.keyTimes = @[@0,@kZoomInTime,@1];
        basic.duration = kTotalTime;
        [btn.layer addAnimation:basic forKey:nil];
        btn.layer.position = [self createEndPointWithRadius:_endRadius andAngel:
                                                        [_angelArray[btn.tag] doubleValue]/180.0];
        
        CABasicAnimation *basic2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        basic2.fromValue = [NSNumber numberWithFloat:0];
        basic2.toValue = [NSNumber numberWithFloat:1];
        basic2.duration = 0.4;
        [btn.layer addAnimation:basic2 forKey:nil];
        btn.layer.opacity = 1;
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
    
    CABasicAnimation *basic3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    basic3.fromValue = [NSNumber numberWithFloat:0];
    basic3.toValue = [NSNumber numberWithFloat:M_PI_4];
    basic3.duration = kTotalTime;
    [_centerBtn.layer addAnimation:basic3 forKey:nil];
    _centerBtn.transform = CGAffineTransformRotate(_centerBtn.transform, M_PI_4);
    
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
    for (UIView *btn in _viewArray) {
        CAKeyframeAnimation *basic = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        basic.values = @[[NSValue valueWithCGPoint:[self createEndPointWithRadius:_endRadius andAngel:
                                                    [_angelArray[btn.tag] doubleValue]/180.0]],
                         [NSValue valueWithCGPoint:[self createEndPointWithRadius:_middleRadius andAngel:
                                                    [_angelArray[btn.tag] doubleValue]/180.0]],
                         [NSValue valueWithCGPoint:CGPointMake(_startRadius, _startRadius)]];
        
        basic.keyTimes = @[@0,@kZoomOutTime,@1.0];
        basic.duration = kTotalTime;
        [btn.layer addAnimation:basic forKey:nil];
        btn.layer.position = CGPointMake(_startRadius, _startRadius);
        
        CABasicAnimation *basic2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        basic2.fromValue = [NSNumber numberWithFloat:1];
        basic2.toValue = [NSNumber numberWithFloat:0];
        basic2.duration = kTotalTime;
        [btn.layer addAnimation:basic2 forKey:nil];
        btn.layer.opacity = 0;
    }
    
    //中间button
    CAKeyframeAnimation *basic2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    basic2.values = @[[NSValue valueWithCGPoint:CGPointMake(_endRadius, _endRadius)],
                      [NSValue valueWithCGPoint:CGPointMake(_middleRadius, _middleRadius)],
                      [NSValue valueWithCGPoint:CGPointMake(_startRadius, _startRadius)]];
    basic2.keyTimes = @[@0,@kZoomOutTime,@1.0];
    basic2.duration = kTotalTime;
    basic2.delegate = self;
    [_centerBtn.layer addAnimation:basic2 forKey:nil];
    _centerBtn.layer.position = CGPointMake(_startRadius, _startRadius);
    
    CABasicAnimation *basic3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    basic3.fromValue = [NSNumber numberWithFloat:M_PI_4];
    basic3.toValue = [NSNumber numberWithFloat:0];
    basic3.duration = kTotalTime;
    [_centerBtn.layer addAnimation:basic3 forKey:nil];
    _centerBtn.transform = CGAffineTransformRotate(_centerBtn.transform, -M_PI_4);
}

- (CGPoint)createEndPointWithRadius:(CGFloat)itemExpandRadius andAngel:(CGFloat)angel
{
    return CGPointMake(itemExpandRadius - cosf(angel * M_PI) * (itemExpandRadius - 50*kWindowWidth/320),
                       itemExpandRadius - sinf(angel * M_PI) * (itemExpandRadius - 50*kWindowWidth/320));
}

-(void)animationDidStart:(CAAnimation *)anim
{
    if ([_delegate respondsToSelector:@selector(centerBtnOnClick)]) {
        [_delegate centerBtnOnClick];
    }
    
}

- (void)buttonClick:(UIButton *)btn{
    switch (btn.tag) {
        case 1:
            if ([_delegate respondsToSelector:@selector(shopBtnOnClick)]) {
                [_delegate shopBtnOnClick];
            }
            break;
        case 2:
            if ([_delegate respondsToSelector:@selector(imageBtnOnClick)]) {
                [_delegate imageBtnOnClick];
            }
            break;
        case 3:
            if ([_delegate respondsToSelector:@selector(videoBtnOnClick)]) {
                [_delegate videoBtnOnClick];
            }
            break;
        default:
            break;
    }
}

@end
