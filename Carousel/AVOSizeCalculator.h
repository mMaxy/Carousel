//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AVOSizeCalculator : NSObject

@property (assign, nonatomic) CGRect rectToFit;
@property (assign, nonatomic, readonly) CGSize cellSize;
@property (assign, nonatomic, readonly) CGSize frameSize;
@property (assign, nonatomic, readonly) CGFloat verticalInset;
@property (assign, nonatomic, readonly) CGFloat horizontalInset;

-(instancetype) initWithRectToFit:(CGRect) rect;

@end