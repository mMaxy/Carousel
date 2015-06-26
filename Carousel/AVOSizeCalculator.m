//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOSizeCalculator.h"


@interface AVOSizeCalculator ()

@end

@implementation AVOSizeCalculator

@synthesize cellSize = _cellSize;
@synthesize rectToFit = _rectToFit;

#pragma mark Inits

- (instancetype) init {
    return [self initWithRectToFit:CGRectZero];
}

- (instancetype)initWithRectToFit:(CGRect)rect {
    if (self = [super init]) {
        [self setRectToFit:rect];
        [self setSpaceBetweenCells:5.f];
    }
    return self;
}

#pragma mark Getters and Setter

- (CGSize)cellSize {
    return _cellSize;
}

- (CGRect)rectToFit {
    return _rectToFit;
}

- (void)setRectToFit:(CGRect)rectToFit {
    BOOL heightDifferent = _rectToFit.size.height != rectToFit.size.height;
    BOOL widthDifferent = _rectToFit.size.width != rectToFit.size.width;
    if (heightDifferent || widthDifferent) {
        _rectToFit = rectToFit;
        [self countCellSizeAndInsets];
    }
}

- (struct Grid)cellFrames {
    struct Grid res;

    res.xLeftCellLeftBorder = self.horizontalInset;
    res.xLeftCellRightBorder = res.xLeftCellLeftBorder + self.cellSize.width;
    res.xCenterCellLeftBorder = res.xLeftCellRightBorder + self.spaceBetweenCells;
    res.xCenterCellRightBorder = res.xCenterCellLeftBorder + self.cellSize.width;
    res.xRightCellLeftBorder = res.xCenterCellRightBorder + self.spaceBetweenCells;
    res.xRightCellRightBorder = res.xRightCellLeftBorder + self.cellSize.width;

    res.yTopCellTopBorder = self.verticalInset;
    res.yTopCellBotBorder = res.yTopCellTopBorder + self.cellSize.height;
    res.yCenterCellTopBorder = res.yTopCellBotBorder + self.spaceBetweenCells;
    res.yCenterCellBotBorder = res.yCenterCellTopBorder + self.cellSize.height;
    res.yBotCellTopBorder = res.yCenterCellBotBorder + self.spaceBetweenCells;
    res.yBotCellBotBorder = res.yBotCellTopBorder + self.cellSize.height;

    return res;
}

- (struct Grid)borders {
    struct Grid res;

    res.xLeftCellLeftBorder = 0.f;
    res.xLeftCellRightBorder = res.xLeftCellLeftBorder + self.cellSize.width + self.horizontalInset + self.spaceBetweenCells / 2;
    res.xCenterCellLeftBorder = res.xLeftCellRightBorder;
    res.xCenterCellRightBorder = res.xCenterCellLeftBorder + self.cellSize.width + self.spaceBetweenCells;
    res.xRightCellLeftBorder = res.xCenterCellRightBorder;
    res.xRightCellRightBorder = res.xRightCellLeftBorder + self.cellSize.width + self.horizontalInset + self.spaceBetweenCells / 2;

    res.yTopCellTopBorder = 0.f;
    res.yTopCellBotBorder = res.yTopCellTopBorder + self.cellSize.height + self.verticalInset + self.spaceBetweenCells / 2;
    res.yCenterCellTopBorder = res.yTopCellBotBorder;
    res.yCenterCellBotBorder = res.yCenterCellTopBorder + self.cellSize.height + self.spaceBetweenCells;
    res.yBotCellTopBorder = res.yCenterCellBotBorder;
    res.yBotCellBotBorder = res.yBotCellTopBorder + self.cellSize.height + self.verticalInset + self.spaceBetweenCells / 2;

    return res;
}

#pragma mark Private Methods

- (void)actualSetCellSize:(CGSize)size andVerticalInset:(CGFloat)vi andHorizontalInset:(CGFloat)hi {
    _cellSize = size;
    _verticalInset = vi;
    _horizontalInset =  hi;

    CGFloat spaceBetweenCells = (_verticalInset > _horizontalInset) ? _horizontalInset : _verticalInset;
    _frameSize = CGSizeMake(( _cellSize.width * 3.f + 4 * spaceBetweenCells), (_cellSize.height * 3.f + 4 * spaceBetweenCells));
}

- (void)countCellSizeAndInsets {
    CGFloat screenWidth = CGRectGetWidth(_rectToFit);
    CGFloat screenHeight = CGRectGetHeight(_rectToFit);

    CGFloat lineSpace = self.spaceBetweenCells;
    CGFloat rowSpace = self.spaceBetweenCells;
    CGFloat horizontalSpace = rowSpace * 4;
    CGFloat verticalSpace = lineSpace * 4;

    CGFloat possibleWidth;
    CGFloat possibleHeight;
    CGFloat totalHeight;
    CGFloat totalWidth;

    CGFloat hi = 0.f;
    CGFloat vi = 0.f;
    CGSize size = CGSizeZero;

    if (!(screenHeight == 0.f || screenWidth == 0.f)) {
        if (screenWidth > screenHeight) {
            // Calculate width and height if additional space on left and right
            possibleHeight = (screenHeight - verticalSpace) / 3;
            possibleWidth = possibleHeight * 3 / 4;
            totalWidth = possibleWidth * 3 + horizontalSpace;

            vi = rowSpace;
            hi = (screenWidth + 2 * lineSpace - totalWidth) / 2;
            size = CGSizeMake(possibleWidth, possibleHeight);
        } else {
            // Calculate width and height if additional space on top and bottom
            possibleWidth = (screenWidth - horizontalSpace) / 3;
            possibleHeight = possibleWidth * 4 / 3;
            totalHeight = possibleHeight * 3 + verticalSpace;

            hi = lineSpace;
            vi = (screenHeight + 2 * rowSpace - totalHeight) / 2;
            size = CGSizeMake(possibleWidth, possibleHeight);
        }
    }

    [self actualSetCellSize:size andVerticalInset:vi andHorizontalInset:hi];
}

@end