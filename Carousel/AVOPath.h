//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AVOSizeCalculator;

@interface AVOPath : NSObject

@property (assign, nonatomic, readonly) CGRect rails;
@property (assign, nonatomic, readonly) CGFloat railsHeightToWidthRelation;
@property (weak, nonatomic) AVOSizeCalculator *sizeCalculator;

- (void)moveCenter:(CGPoint *)center byAngle:(double) angle;
- (CGPoint)getCenterForIndex:(NSUInteger) index;
- (CGPoint)getCenterForIndexPath:(NSIndexPath *) indexPath;

- (CGFloat)getNearestFixedPositionFrom:(CGFloat)currentPosition;

- (NSIndexPath *)getCellIndexWithPoint:(CGPoint) point;

- (NSIndexPath *)getNearestCellIndexFromPoint:(CGPoint) point
                          withResultDirection:(CGPoint *) direction
                            andResultDistance:(CGFloat *) distance;


@end