//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

struct Grid
{
    CGFloat xLeftCellLeftBorder;
    CGFloat xLeftCellRightBorder;
    CGFloat xCenterCellLeftBorder;
    CGFloat xCenterCellRightBorder;
    CGFloat xRightCellLeftBorder;
    CGFloat xRightCellRightBorder;

    CGFloat yTopCellTopBorder;
    CGFloat yTopCellBotBorder;
    CGFloat yCenterCellTopBorder;
    CGFloat yCenterCellBotBorder;
    CGFloat yBotCellTopBorder;
    CGFloat yBotCellBotBorder;
};

@interface AVOSizeCalculator : NSObject

@property (assign, nonatomic) CGRect rectToFit;

@property (assign, nonatomic, readonly) CGSize cellSize;
@property (assign, nonatomic, readonly) CGSize frameSize;

@property (assign, nonatomic) CGFloat spaceBetweenCells;
@property (assign, nonatomic, readonly) CGFloat verticalInset;
@property (assign, nonatomic, readonly) CGFloat horizontalInset;

@property (assign, nonatomic, readonly) struct Grid borders;
@property (assign, nonatomic, readonly) struct Grid cellFrames;

-(instancetype) initWithRectToFit:(CGRect) rect;

@end