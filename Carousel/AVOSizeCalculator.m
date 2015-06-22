//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOSizeCalculator.h"


@interface AVOSizeCalculator ()

@property (assign, nonatomic) BOOL isRectChanged;

@end

@implementation AVOSizeCalculator

@synthesize cellSize = _cellSize;
@synthesize rectToFit = _rectToFit;

#pragma mark INITIALIZERS

- (instancetype) init {
    return [self initWithRectToFit:CGRectZero];
}

- (instancetype)initWithRectToFit:(CGRect)rect {
    if (self = [super init]) {
        [self setRectToFit:rect];
    }
    return self;
}

#pragma mark GETTERS AND SETTER

- (CGSize)cellSize {
    if (_isRectChanged) {
        CGFloat screenWidth = CGRectGetWidth(_rectToFit);
        CGFloat screenHeight = CGRectGetHeight(_rectToFit);

        CGFloat lineSpace = 5.f;
        CGFloat rowSpace = 5.f;
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

        _isRectChanged = NO;
    }

    return _cellSize;
}

- (CGRect)rectToFit {
    return _rectToFit;
}

- (void)setRectToFit:(CGRect)rectToFit {
    _isRectChanged = YES;
    _rectToFit = rectToFit;
}

#pragma mark PRIVATE METHODS

- (void)actualSetCellSize:(CGSize)size andVerticalInset:(CGFloat)vi andHorizontalInset:(CGFloat)hi {
    _cellSize = size;
    _verticalInset = vi;
    _horizontalInset =  hi;

    CGFloat spaceBetweenCells = (_verticalInset > _horizontalInset) ? _horizontalInset : _verticalInset;
    _frameSize = CGSizeMake(( _cellSize.width * 3.f + 4 * spaceBetweenCells), (_cellSize.height * 3.f + 4 * spaceBetweenCells));
}

@end