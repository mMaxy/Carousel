//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOPath.h"
#import "AVOSizeCalculator.h"
#import "AVOGeometryCalculations.h"

@interface AVOPath ()

@property(strong, nonatomic, readonly) NSArray *possibleOutcomes;

- (NSArray *)findSectorHitWithPoint:(CGPoint)point borders:(struct Grid)borders;

- (NSUInteger)calculateIndexForArray:(NSArray *)result;

- (NSUInteger)findIndexForPoint:(CGPoint)point inGrid:(struct Grid)grid;

@end

@implementation AVOPath {
    NSArray *_possibleOutcomes;
}

@dynamic possibleOutcomes;

#pragma mark - Setters

- (void)setSizeCalculator:(AVOSizeCalculator *)sizeCalculator {
    _sizeCalculator = sizeCalculator;
    CGFloat railYMin = [self calculateCenterForIndex:2].y;
    CGFloat railYMax = [self calculateCenterForIndex:4].y;
    CGFloat railXMin = [self calculateCenterForIndex:0].x;
    CGFloat railXMax = [self calculateCenterForIndex:2].x;
    _rails = CGRectMake(railXMin, railXMin, railXMax - railXMin, railXMax - railXMin);
    _railsHeightToWidthRelation = (railYMax - railYMin) / (railXMax - railXMin);
}

#pragma mark - Interface realization

- (CGRect)frameForCardAtIndex:(NSUInteger)index withOffset:(CGFloat)offset {
    CGRect frame = CGRectZero;

    frame.size = [self.sizeCalculator cellSize];
    CGPoint center = [self calculateCenterForIndex:index];
    if (index != 8) {
        [self moveCenter:&center byAngle:offset];
    }

    frame.origin = CGPointMake(center.x - frame.size.width / 2, center.y - frame.size.height / 2);

    return frame;
}

- (void)moveCenter:(CGPoint *)center byAngle:(double)angle {
    CGPoint p = (*center);
    double remain = angle;

    CGRect f = self.rails;

    p.x = p.x - self.sizeCalculator.horizontalInset - self.sizeCalculator.cellSize.width / 2;
    p.y = p.y - self.sizeCalculator.verticalInset - self.sizeCalculator.cellSize.height / 2;
    p.y *= 1 / self.railsHeightToWidthRelation;

    CGPoint rotated = [AVOGeometryCalculations calculateRotatedPointFromPoint:p byAngle:remain inFrame:f];

    rotated.y *= self.railsHeightToWidthRelation;
    rotated.x = rotated.x + self.sizeCalculator.horizontalInset + self.sizeCalculator.cellSize.width / 2;
    rotated.y = rotated.y + self.sizeCalculator.verticalInset + self.sizeCalculator.cellSize.height / 2;

    (*center) = CGPointMake(rotated.x, rotated.y);
}

- (CGPoint)calculateCenterForIndex:(NSUInteger)i {
    CGPoint result;

    CGFloat leftColumn = self.sizeCalculator.cellSize.width * 1 / 2 + self.sizeCalculator.horizontalInset;
    CGFloat centerColumn = self.sizeCalculator.cellSize.width * 3 / 2 + self.sizeCalculator.horizontalInset + self.sizeCalculator.spaceBetweenCells;
    CGFloat rightColumn = self.sizeCalculator.cellSize.width * 5 / 2 + self.sizeCalculator.horizontalInset + self.sizeCalculator.spaceBetweenCells * 2;

    CGFloat topRow = self.sizeCalculator.cellSize.height * 1 / 2 + self.sizeCalculator.verticalInset;
    CGFloat centerRow = self.sizeCalculator.cellSize.height * 3 / 2 + self.sizeCalculator.verticalInset + self.sizeCalculator.spaceBetweenCells;
    CGFloat botRow = self.sizeCalculator.cellSize.height * 5 / 2 + self.sizeCalculator.verticalInset + self.sizeCalculator.spaceBetweenCells * 2;

    CGFloat x = 0.f;
    CGFloat y = 0.f;

    if ([@[@(0), @(6), @(7)] containsObject:@(i)]) {
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

- (CGPoint)calculateCenterForIndexPath:(NSUInteger)indexPath {
    CGPoint result;

    result = [self calculateCenterForIndex:indexPath];

    return result;
}


- (NSUInteger)findCellIndexWithPoint:(CGPoint)point {
    NSUInteger res = 0;

    struct Grid frames = self.sizeCalculator.cellFrames;
    res = [self findIndexForPoint:point inGrid:frames];

    return res;
}

- (NSUInteger)findIndexForCellWithPoint:(CGPoint)point withOffset:(CGFloat)offset {
    NSUInteger index = [self findCellIndexWithPoint:point];
    if (index != 8) {
        point = [self calculateCenterForIndexPath:index];

        [self moveCenter:&point byAngle:-offset];
    }
    index = [self findCellIndexWithPoint:point];
    return index;
}

- (CGFloat)findNearestFixedPositionFrom:(CGFloat)currentPosition {
    CGFloat moveToAngle = currentPosition;
    if (currentPosition < M_PI_4 / 2 && currentPosition > 0) {
        moveToAngle = 0;
    } else if (currentPosition < 3 * M_PI_4 / 2 && currentPosition > M_PI_4 / 2) {
        moveToAngle = (CGFloat) M_PI_4;
    } else if (currentPosition < 5 * M_PI_4 / 2 && currentPosition > 3 * M_PI_4 / 2) {
        moveToAngle = (CGFloat) M_PI_2;
    } else if (currentPosition < 7 * M_PI_4 / 2 && currentPosition > 5 * M_PI_4 / 2) {
        moveToAngle = (CGFloat) (3 * M_PI_4);
    } else if (currentPosition < 9 * M_PI_4 / 2 && currentPosition > 7 * M_PI_4 / 2) {
        moveToAngle = (CGFloat) M_PI;
    } else if (currentPosition < 11 * M_PI_4 / 2 && currentPosition > 9 * M_PI_4 / 2) {
        moveToAngle = (CGFloat) (5 * M_PI_4);
    } else if (currentPosition < 13 * M_PI_4 / 2 && currentPosition > 11 * M_PI_4 / 2) {
        moveToAngle = (CGFloat) (3 * M_PI_2);
    } else if (currentPosition < 15 * M_PI_4 / 2 && currentPosition > 13 * M_PI_4 / 2) {
        moveToAngle = (CGFloat) (7 * M_PI_4);
    } else if (currentPosition < 16 * M_PI_4 / 2 && currentPosition > 15 * M_PI_4 / 2) {
        moveToAngle = (CGFloat) (2 * M_PI);
    }
    return moveToAngle;
}

#pragma mark Private methods

- (NSArray *)possibleOutcomes {
    if (!_possibleOutcomes) {
        _possibleOutcomes = @[
                @[
                        @(0),
                        @(1),
                        @(2)
                ],
                @[
                        @(7),
                        @(8),
                        @(3)
                ],
                @[
                        @(6),
                        @(5),
                        @(4)
                ]
        ];
    }

    return _possibleOutcomes;
}

- (NSArray *)findSectorHitWithPoint:(CGPoint)point borders:(struct Grid)borders {
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

- (NSUInteger)calculateIndexForArray:(NSArray *)result {
    NSUInteger res = 0;
    for (NSUInteger i = 0; i < [[self possibleOutcomes] count]; i++) {
        for (NSUInteger y = 0; y < [[self possibleOutcomes][i] count]; y++) {
            if ([result[i][y] boolValue]) {
                res = [[self possibleOutcomes][i][y] unsignedIntegerValue];
            }
        }
    }
    return res;
}

- (NSUInteger)findIndexForPoint:(CGPoint)point inGrid:(struct Grid)grid {
    NSUInteger res = 0;
    NSArray *result = [self findSectorHitWithPoint:point borders:grid];
    res = [self calculateIndexForArray:result];
    return res;
}

@end