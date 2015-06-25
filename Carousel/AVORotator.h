//
// Created by Artem Olkov on 25/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class AVOSizeCalculator;


@interface AVORotator : NSObject

-(CGPoint)rotatedPointFromPoint:(CGPoint)from byAngle:(double)angle inFrame:(CGRect)frame;

@end