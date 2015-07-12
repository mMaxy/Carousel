//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOPath.h"
#import "AVOSizeCalculator.h"
#import "AVORotator.h"

@interface AVOPath ()

@property (strong, nonatomic, readonly) NSArray *possibleOutcomes;

- (void)setDistance:(CGFloat *)distance andDirection:(CGPoint *)direction fromPoint:(CGPoint)from toPoint:(CGPoint)to;

- (NSArray *)getSectorHitWithPoint:(CGPoint)point borders:(struct Grid)borders;


@end

@implementation AVOPath {
    NSArray *_possibleOutcomes;
}

@dynamic possibleOutcomes;

- (void)setSizeCalculator:(AVOSizeCalculator *)sizeCalculator {
    _sizeCalculator = sizeCalculator;
    CGFloat railYMin = [self getCenterForIndex:2].y;
    CGFloat railYMax = [self getCenterForIndex:4].y;
    CGFloat railXMin = [self getCenterForIndex:0].x;
    CGFloat railXMax = [self getCenterForIndex:2].x;
    _rails = CGRectMake(railXMin, railXMin, railXMax-railXMin, railXMax-railXMin);
    _railsHeightToWidthRelation = (railYMax-railYMin) / (railXMax-railXMin);
}

- (void)moveCenter:(CGPoint *)center byAngle:(double) angle {
    CGPoint p = (*center);
    double remain = angle;

    CGRect f = self.rails;

    p.x = p.x - self.sizeCalculator.horizontalInset - self.sizeCalculator.cellSize.width/2;
    p.y = p.y - self.sizeCalculator.verticalInset - self.sizeCalculator.cellSize.height/2;
    p.y *= 1/self.railsHeightToWidthRelation;

    CGPoint rotated = [AVORotator rotatedPointFromPoint:p byAngle:remain inFrame:f];

    rotated.y *=  self.railsHeightToWidthRelation;
    rotated.x = rotated.x + self.sizeCalculator.horizontalInset + self.sizeCalculator.cellSize.width/2;
    rotated.y = rotated.y + self.sizeCalculator.verticalInset + self.sizeCalculator.cellSize.height/2;

    (*center) = CGPointMake(rotated.x , rotated.y);
}

- (CGPoint)getCenterForIndex:(NSUInteger) i {
    CGPoint result;

    CGFloat leftColumn   = self.sizeCalculator.cellSize.width * 1 / 2 + self.sizeCalculator.horizontalInset ;
    CGFloat centerColumn = self.sizeCalculator.cellSize.width * 3 / 2 + self.sizeCalculator.horizontalInset + self.sizeCalculator.spaceBetweenCells;
    CGFloat rightColumn  = self.sizeCalculator.cellSize.width * 5 / 2 + self.sizeCalculator.horizontalInset + self.sizeCalculator.spaceBetweenCells * 2;

    CGFloat topRow    = self.sizeCalculator.cellSize.height * 1 / 2 + self.sizeCalculator.verticalInset ;
    CGFloat centerRow = self.sizeCalculator.cellSize.height * 3 / 2 + self.sizeCalculator.verticalInset + self.sizeCalculator.spaceBetweenCells;
    CGFloat botRow    = self.sizeCalculator.cellSize.height * 5 / 2 + self.sizeCalculator.verticalInset + self.sizeCalculator.spaceBetweenCells * 2;

    CGFloat x = 0.f;
    CGFloat y = 0.f;

    if ([@[@(0), @(6), @(7)] containsObject:@(i)]){
        x = leftColumn;
    } else if ([@[@(1), @(5), @(8)] containsObject:@(i)]) {
        x = centerColumn;
    } else if ([@[@(2), @(3), @(4)] containsObject:@(i)]) {
        x = rightColumn;
    }

    if ([@[@(0), @(1), @(2)] containsObject:@(i)]) {
        y = topRow;
    } else if ([@[@(7), @(8), @(3)] containsObject:@(i)]) {
        y = centerRow;
    } else if ([@[@(6), @(5), @(4)] containsObject:@(i)]) {
        y = botRow;
    }

    result = CGPointMake(x, y);

    return result;
}

- (CGPoint)getCenterForIndexPath:(NSIndexPath *)indexPath {
    CGPoint result;

    result = [self getCenterForIndex:(NSUInteger) indexPath.item];

    return result;
}


- (NSIndexPath *)getCellIndexWithPoint:(CGPoint)point {
    NSIndexPath *res = nil;

    struct Grid frames = self.sizeCalculator.cellFrames;
    res = [self getPathForPoint:point inGrid:frames];

    return res;
}

- (NSIndexPath *)getNearestCellIndexFromPoint:(CGPoint)point withResultDirection:(CGPoint *)direction andResultDistance:(CGFloat *)distance {
    NSIndexPath *res = nil;

    struct Grid borders = self.sizeCalculator.borders;
    res = [self getPathForPoint:point inGrid:borders];

    CGPoint center = [self getCenterForIndexPath:res];

    [self setDistance:distance andDirection:direction fromPoint:point toPoint:center];

    return res;
}



- (CGFloat)getNearestFixedPositionFrom:(CGFloat)currentPosition {
    CGFloat moveToAngle = currentPosition;
    if (currentPosition < M_PI_4/2 && currentPosition > 0) {
        moveToAngle = 0;
    } else if (currentPosition < 3 * M_PI_4/2 && currentPosition > M_PI_4/2) {
        moveToAngle = (CGFloat) M_PI_4;
    } else if (currentPosition < 5 * M_PI_4/2 && currentPosition > 3 * M_PI_4/2) {
        moveToAngle = (CGFloat) M_PI_2;
    } else if (currentPosition < 7 * M_PI_4/2 && currentPosition > 5 * M_PI_4/2) {
        moveToAngle = (CGFloat) (3*M_PI_4);
    } else if (currentPosition < 9 * M_PI_4/2 && currentPosition > 7 * M_PI_4/2) {
        moveToAngle = (CGFloat) M_PI;
    } else if (currentPosition < 11 * M_PI_4/2 && currentPosition > 9 * M_PI_4/2) {
        moveToAngle = (CGFloat) (5*M_PI_4);
    } else if (currentPosition < 13 * M_PI_4/2 && currentPosition > 11 * M_PI_4/2) {
        moveToAngle = (CGFloat) (3*M_PI_2);
    } else if (currentPosition < 15 * M_PI_4/2 && currentPosition > 13 * M_PI_4/2) {
        moveToAngle = (CGFloat) (7*M_PI_4);
    } else if (currentPosition < 16 * M_PI_4/2 && currentPosition > 15 * M_PI_4/2) {
        moveToAngle = (CGFloat) (2*M_PI);
    }
    return moveToAngle;
}

#pragma mark Private methods

- (NSArray *)possibleOutcomes {
    if (!_possibleOutcomes) {
        _possibleOutcomes = @[
                @[
                        [NSIndexPath indexPathForItem:0 inSection:0],
                        [NSIndexPath indexPathForItem:1 inSection:0],
                        [NSIndexPath indexPathForItem:2 inSection:0]
                ],
                @[
                        [NSIndexPath indexPathForItem:7 inSection:0],
                        [NSIndexPath indexPathForItem:8 inSection:0],
                        [NSIndexPath indexPathForItem:3 inSection:0]
                ],
                @[
                        [NSIndexPath indexPathForItem:6 inSection:0],
                        [NSIndexPath indexPathForItem:5 inSection:0],
                        [NSIndexPath indexPathForItem:4 inSection:0]
                ]
        ];
    }

    return _possibleOutcomes;
}

- (NSArray *)getSectorHitWithPoint:(CGPoint)point borders:(struct Grid)borders {
    BOOL pointInLeftColumn = point.x >= borders.xLeftCellLeftBorder && point.x <= borders.xLeftCellRightBorder;
    BOOL pointInCenterColumn = point.x >= borders.xCenterCellLeftBorder && point.x <= borders.xCenterCellRightBorder;
    BOOL pointInRightColumn = point.x >= borders.xRightCellLeftBorder && point.x <= borders.xRightCellRightBorder;

    BOOL pointInTopRow = point.y >= borders.yTopCellTopBorder && point.y <= borders.yTopCellBotBorder;
    BOOL pointInCenterRow = point.y >= borders.yCenterCellTopBorder && point.y <= borders.yCenterCellBotBorder;
    BOOL pointInBotRow = point.y >= borders.yBotCellTopBorder && point.y <= borders.yBotCellBotBorder;

    NSArray *result = @[
            @[
                    @(pointInTopRow && pointInLeftColumn),
                    @(pointInTopRow && pointInCenterColumn),
                    @(pointInTopRow && pointInRightColumn)
            ],
            @[
                    @(pointInCenterRow && pointInLeftColumn),
                    @(pointInCenterRow && pointInCenterColumn),
                    @(pointInCenterRow && pointInRightColumn)
            ],
            @[
                    @(pointInBotRow && pointInLeftColumn),
                    @(pointInBotRow && pointInCenterColumn),
                    @(pointInBotRow && pointInRightColumn)
            ]
    ];
    return result;
}

- (NSIndexPath *)getPathForArray:(NSArray *)result {
    NSIndexPath *res;
    for (NSUInteger i = 0; i < [[self possibleOutcomes] count]; i++) {
        for (NSUInteger y = 0; y < [[self possibleOutcomes][i] count]; y++) {
            if ([result[i][y] boolValue]) {
                res = [self possibleOutcomes][i][y];
            }
        }
    }
    return res;
}

- (NSIndexPath *)getPathForPoint:(CGPoint)point inGrid:(struct Grid)grid {
    NSIndexPath *res;
    NSArray *result = [self getSectorHitWithPoint:point borders:grid];
    res = [self getPathForArray:result];
    return res;
}

- (void)setDistance:(CGFloat *)distance andDirection:(CGPoint *)direction fromPoint:(CGPoint)from toPoint:(CGPoint)to {
    CGFloat x = to.x - from.x;
    CGFloat y = to.y - from.y;

    CGFloat dist = (CGFloat) sqrt(x*x + y*y);

    x /= dist;
    y /= dist;

    *direction = CGPointMake(x, y);
    *distance = dist;
}

@end