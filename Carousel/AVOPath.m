//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOPath.h"
#import "AVOSizeCalculator.h"

@interface AVOPath ()

@property (strong, nonatomic, readonly) NSArray *possibleOutcomes;

- (void)setDistance:(CGFloat *)distance andDirection:(CGPoint *)direction fromPoint:(CGPoint)from toPoint:(CGPoint)to;

- (NSArray *)getSectorHitWithPoint:(CGPoint)point borders:(struct Grid)borders;

- (NSIndexPath *)getPathForArray:(NSArray *)result;

- (NSIndexPath *)getPathForPoint:(CGPoint)point inGrid:(struct Grid)grid;
@end

@implementation AVOPath {
    NSArray *_possibleOutcomes;
}

@dynamic possibleOutcomes;

- (CGPoint)getCenterForIndex:(NSUInteger) i {
    CGPoint result;

    CGFloat leftColumn   = self.sizeCalculator.cellSize.width * 1 / 2 + self.sizeCalculator.horizontalInset * 1;
    CGFloat centerColumn = self.sizeCalculator.cellSize.width * 3 / 2 + self.sizeCalculator.horizontalInset * 2;
    CGFloat rightColumn  = self.sizeCalculator.cellSize.width * 5 / 2 + self.sizeCalculator.horizontalInset * 3;

    CGFloat topRow    = self.sizeCalculator.cellSize.height * 1 / 2 + self.sizeCalculator.verticalInset * 1;
    CGFloat centerRow = self.sizeCalculator.cellSize.height * 3 / 2 + self.sizeCalculator.verticalInset * 2;
    CGFloat botRow    = self.sizeCalculator.cellSize.height * 5 / 2 + self.sizeCalculator.verticalInset * 3;

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

- (NSArray *)getIndexesInRect:(CGRect)rect {
    CGFloat fromX = rect.origin.x;
    CGFloat toX = fromX + rect.size.width;
    CGFloat fromY = rect.origin.y;
    CGFloat toY = fromY + rect.size.height;
    NSMutableArray *matrix;
    NSMutableArray *res = [NSMutableArray new];

    struct Grid frames = self.sizeCalculator.cellFrames;
    matrix = [[self possibleOutcomes] mutableCopy];
    for (NSUInteger index = 0; index < [matrix count]; index ++) {
        matrix[index] = [matrix[index] mutableCopy];
    }

    //remove all index that impossible by starting X coordinate
    NSArray *tmp = @[@(frames.xLeftCellRightBorder), @(frames.xCenterCellRightBorder), @(frames.xRightCellRightBorder)];
    for (NSUInteger column = 0; column < [matrix count]; column++) {
        if (fromX >= [tmp[column] floatValue]) {
            matrix[0] [column] = [NSNull null];
            matrix[1] [column] = [NSNull null];
            matrix[2] [column] = [NSNull null];
        }
    }

    //remove all index that impossible by starting Y coordinate
    tmp = @[@(frames.yTopCellBotBorder), @(frames.yCenterCellBotBorder), @(frames.yBotCellBotBorder)];
    for (NSUInteger row = 0; row < [matrix[0] count]; row++) {
        if (fromY >= [tmp[row] floatValue]) {
            matrix[row] [0] = [NSNull null];
            matrix[row] [1] = [NSNull null];
            matrix[row] [2] = [NSNull null];
        }
    }

    //remove all index that impossible by ending X coordinate
    if (toX <= frames.xRightCellLeftBorder) {
        matrix[0] [2] = [NSNull null];
        matrix[1] [2] = [NSNull null];
        matrix[2] [2] = [NSNull null];
    }
    if (toX <= frames.xCenterCellLeftBorder) {
        matrix[0] [1] = [NSNull null];
        matrix[1] [1] = [NSNull null];
        matrix[2] [1] = [NSNull null];
    }
    if (toX <= frames.xLeftCellLeftBorder) {
        matrix[0] [0] = [NSNull null];
        matrix[1] [0] = [NSNull null];
        matrix[2] [0] = [NSNull null];
    }
    //remove all index that impossible by ending Y coordinate
    if (toY <= frames.yBotCellTopBorder) {
        matrix[2] [0] = [NSNull null];
        matrix[2] [1] = [NSNull null];
        matrix[2] [2] = [NSNull null];
    }
    if (toY <= frames.yCenterCellTopBorder) {
        matrix[1] [0] = [NSNull null];
        matrix[1] [1] = [NSNull null];
        matrix[1] [2] = [NSNull null];
    }
    if (toY <= frames.yTopCellTopBorder) {
        matrix[0] [0] = [NSNull null];
        matrix[0] [1] = [NSNull null];
        matrix[0] [2] = [NSNull null];
    }

    for (NSUInteger i = 0; i < [matrix count]; i++) {
        for (NSUInteger y = 0; y < [matrix[i] count]; y++) {
            if (matrix[i][y] != [NSNull null]) {
                [res addObject:matrix[i][y]];
            }
        }
    }

    return [res copy];
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