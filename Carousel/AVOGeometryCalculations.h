//
// Created by Artem Olkov on 25/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AVOSpinDirection) {
    AVOSpinNone = 0,
    AVOSpinClockwise,
    AVOSpinCounterClockwise
};

@class AVOSizeCalculator;


@interface AVOGeometryCalculations : NSObject

+ (CGPoint)calculateRotatedPointFromPoint:(CGPoint)from byAngle:(double)angle inFrame:(CGRect)frame;

+ (CGFloat)calculateAngleFromPoint:(CGPoint)point onFrame:(CGRect)frame;

+ (CGPoint)calculatePointForAngle:(double)angle onFrame:(CGRect)frame;

+ (AVOSpinDirection)calculateSpinDirectionForVector:(CGPoint)vector fromPoint:(CGPoint)point onFrame:(CGRect)frame;

@end