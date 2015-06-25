//
// Created by Artem Olkov on 25/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class AVOSizeCalculator;


@interface AVORotator : NSObject

-(CGPoint) rotateFromAngle:(CGFloat)from toAngle:(CGFloat)to inFrame:(CGRect)frame;

@end