//
// Created by Artem Olkov on 22/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AVOSizeCalculator;

@interface AVOPath : NSObject

@property (weak, nonatomic) AVOSizeCalculator *sizeCalculator;

- (CGPoint)getCenterForIndex:(NSUInteger) i;

@end