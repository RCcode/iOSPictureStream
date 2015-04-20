//
//  BloomView.h
//  YRUK
//
//  Created by lisongrc on 15-4-8.
//  Copyright (c) 2015年 rcplatform. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BloomDelegate <NSObject>

- (void)centerBtnOnClick;
- (void)imageBtnOnClick;
- (void)videoBtnOnClick;
- (void)shopBtnOnClick;

@end

@interface PS_BloomView : UIView

@property (nonatomic, weak) id<BloomDelegate> delegate;

- (void)bloomAnimation;
- (void)cancelAnimation;

@end
