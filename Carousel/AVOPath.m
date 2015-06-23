//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOPath.h"
#import "AVOSizeCalculator.h"

@interface AVOPath ()

@end

@implementation AVOPath


//TODO change indexes
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

    if ([@[@(1), @(7), @(8)] containsObject:@(i)]){
        x = leftColumn;
    } else if ([@[@(2), @(6), @(0)] containsObject:@(i)]) {
        x = centerColumn;
    } else if ([@[@(3), @(4), @(5)] containsObject:@(i)]) {
        x = rightColumn;
    }

    if ([@[@(1), @(2), @(3)] containsObject:@(i)]) {
        y = topRow;
    } else if ([@[@(8), @(9), @(4)] containsObject:@(i)]) {
        y = centerRow;
    } else if ([@[@(7), @(6), @(5)] containsObject:@(i)]) {
        y = botRow;
    }

    result = CGPointMake(x, y);

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
    CGFloat yTopCellBotBorder = yTopCellTopBorder + self.sizeCalculator.cellSize.width;
    CGFloat yCenterCellTopBorder = yTopCellBotBorder + self.sizeCalculator.spaceBetweenCells;
    CGFloat yCenterCellBotBorder = yCenterCellTopBorder + self.sizeCalculator.cellSize.width;
    CGFloat yBotCellTopBorder = yCenterCellBotBorder + self.sizeCalculator.spaceBetweenCells;
    CGFloat yBotCellBotBorder = yBotCellTopBorder + self.sizeCalculator.cellSize.width;

    BOOL pointInLeftColumn = point.x >= xLeftCellLeftBorder && point.x <= xLeftCellRightBorder;
    BOOL pointInCenterColumn = point.x >= xCenterCellLeftBorder && point.x <= xCenterCellRightBorder;
    BOOL pointInRightColumn = point.x >= xRightCellLeftBorder && point.x <= xRightCellRightBorder;

    BOOL pointInTopRow = point.y >= yTopCellTopBorder && point.y <= yTopCellBotBorder;
    BOOL pointInCenterRow = point.y >= yCenterCellTopBorder && point.y <= yCenterCellBotBorder;
    BOOL pointInBotRow = point.y >= yBotCellTopBorder && point.y <= yBotCellBotBorder;

    NSArray *possibleOutcomes = @[
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

    for (int i = 0; i < [possibleOutcomes count]; i++) {
        for (int y = 0; y < [possibleOutcomes[i] count]; y++) {
            if ([result[i][y] boolValue]) {
                res = possibleOutcomes[i][y];
            }
        }

    }

    return res;
}

- (NSIndexPath *)getNearestCellIndexFromPoint:(CGPoint)point withResultDirection:(CGPoint *)direction andResultDistance:(CGFloat *)distance {
    return nil;
}

- (NSArray *)getIndexesInRect:(CGRect)rect {
    return nil;
}


@end