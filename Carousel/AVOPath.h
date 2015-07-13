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

- (CGRect)frameForCardAtIndex:(NSUInteger)index withOffset:(CGFloat) offset;

- (void)moveCenter:(CGPoint *)center byAngle:(double) angle;

- (CGPoint)calculateCenterForIndex:(NSUInteger) index;
- (CGPoint)calculateCenterForIndexPath:(NSUInteger) indexPath;

- (NSUInteger)findIndexForCellWithPoint:(CGPoint)point withOffset:(CGFloat)offset;

- (CGFloat)findNearestFixedPositionFrom:(CGFloat)currentPosition;

- (NSUInteger)findCellIndexWithPoint:(CGPoint) point;

@end