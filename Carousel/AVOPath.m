//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOPath.h"
#import "AVOSizeCalculator.h"

@interface AVOPath ()

@property (strong, nonatomic, readonly) NSArray *possibleOutcomes;

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

    result = [self getCenterForIndex:indexPath.item];

    return result;
}


- (NSIndexPath *)getCellIndexWithPoint:(CGPoint)point {
    NSIndexPath *res = nil;

    CGFloat xLeftCellLeftBorder = self.sizeCalculator.horizontalInset;
    CGFloat xLeftCellRightBorder = xLeftCellLeftBorder + self.sizeCalculator.cellSize.width;
    CGFloat xCenterCellLeftBorder = xLeftCellRightBorder + self.sizeCalculator.spaceBetweenCells;
    CGFloat xCenterCellRightBorder = xCenterCellLeftBorder + self.sizeCalculator.cellSize.width;
    CGFloat xRightCellLeftBorder = xCenterCellRightBorder + self.sizeCalculator.spaceBetweenCells;
    CGFloat xRightCellRightBorder = xRightCellLeftBorder + self.sizeCalculator.cellSize.width;

    CGFloat yTopCellTopBorder = self.sizeCalculator.horizontalInset;
    CGFloat yTopCellBotBorder = yTopCellTopBorder + self.sizeCalculator.cellSize.height;
    CGFloat yCenterCellTopBorder = yTopCellBotBorder + self.sizeCalculator.spaceBetweenCells;
    CGFloat yCenterCellBotBorder = yCenterCellTopBorder + self.sizeCalculator.cellSize.height;
    CGFloat yBotCellTopBorder = yCenterCellBotBorder + self.sizeCalculator.spaceBetweenCells;
    CGFloat yBotCellBotBorder = yBotCellTopBorder + self.sizeCalculator.cellSize.height;

    BOOL pointInLeftColumn = point.x >= xLeftCellLeftBorder && point.x <= xLeftCellRightBorder;
    BOOL pointInCenterColumn = point.x >= xCenterCellLeftBorder && point.x <= xCenterCellRightBorder;
    BOOL pointInRightColumn = point.x >= xRightCellLeftBorder && point.x <= xRightCellRightBorder;

    BOOL pointInTopRow = point.y >= yTopCellTopBorder && point.y <= yTopCellBotBorder;
    BOOL pointInCenterRow = point.y >= yCenterCellTopBorder && point.y <= yCenterCellBotBorder;
    BOOL pointInBotRow = point.y >= yBotCellTopBorder && point.y <= yBotCellBotBorder;

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

    for (NSUInteger i = 0; i < [[self possibleOutcomes] count]; i++) {
        for (NSUInteger y = 0; y < [[self possibleOutcomes][i] count]; y++) {
            if ([result[i][y] boolValue]) {
                res = [self possibleOutcomes][i][y];
            }
        }
    }

    return res;
}

- (NSIndexPath *)getNearestCellIndexFromPoint:(CGPoint)point withResultDirection:(CGPoint *)direction andResultDistance:(CGFloat *)distance {
    NSIndexPath *res = nil;

    CGFloat xLeftCellLeftBorder = 0.f;
    CGFloat xLeftCellRightBorder = xLeftCellLeftBorder + self.sizeCalculator.cellSize.width + self.sizeCalculator.horizontalInset + self.sizeCalculator.spaceBetweenCells / 2;
    CGFloat xCenterCellLeftBorder = xLeftCellRightBorder;
    CGFloat xCenterCellRightBorder = xCenterCellLeftBorder + self.sizeCalculator.cellSize.width + self.sizeCalculator.spaceBetweenCells;
    CGFloat xRightCellLeftBorder = xCenterCellRightBorder;
    CGFloat xRightCellRightBorder = xRightCellLeftBorder + self.sizeCalculator.cellSize.width + self.sizeCalculator.horizontalInset + self.sizeCalculator.spaceBetweenCells / 2;

    CGFloat yTopCellTopBorder = 0.f;
    CGFloat yTopCellBotBorder = yTopCellTopBorder + self.sizeCalculator.cellSize.height + self.sizeCalculator.verticalInset + self.sizeCalculator.spaceBetweenCells / 2;
    CGFloat yCenterCellTopBorder = yTopCellBotBorder;
    CGFloat yCenterCellBotBorder = yCenterCellTopBorder + self.sizeCalculator.cellSize.height + self.sizeCalculator.spaceBetweenCells;
    CGFloat yBotCellTopBorder = yCenterCellBotBorder;
    CGFloat yBotCellBotBorder = yBotCellTopBorder + self.sizeCalculator.cellSize.height + self.sizeCalculator.verticalInset + self.sizeCalculator.spaceBetweenCells / 2;

    BOOL pointInLeftColumn = point.x >= xLeftCellLeftBorder && point.x <= xLeftCellRightBorder;
    BOOL pointInCenterColumn = point.x >= xCenterCellLeftBorder && point.x <= xCenterCellRightBorder;
    BOOL pointInRightColumn = point.x >= xRightCellLeftBorder && point.x <= xRightCellRightBorder;

    BOOL pointInTopRow = point.y >= yTopCellTopBorder && point.y <= yTopCellBotBorder;
    BOOL pointInCenterRow = point.y >= yCenterCellTopBorder && point.y <= yCenterCellBotBorder;
    BOOL pointInBotRow = point.y >= yBotCellTopBorder && point.y <= yBotCellBotBorder;

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

    for (NSUInteger i = 0; i < [[self possibleOutcomes] count]; i++) {
        for (NSUInteger y = 0; y < [[self possibleOutcomes][i] count]; y++) {
            if ([result[i][y] boolValue]) {
                res = [self possibleOutcomes][i][y];
            }
        }
    }

    CGPoint center = [self getCenterForIndexPath:res];

    CGFloat x = center.x - point.x;
    CGFloat y = center.y - point.y;

    CGFloat dist = (CGFloat) sqrt(x*x + y*y);

    x /= dist;
    y /= dist;

    *direction = CGPointMake(x, y);
    *distance = dist;

    return res;
}

- (NSArray *)getIndexesInRect:(CGRect)rect {
    return nil;
}

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


@end