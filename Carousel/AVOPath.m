//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOPath.h"
#import "AVOSizeCalculator.h"

@interface AVOPath ()

@end

@implementation AVOPath

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

@end