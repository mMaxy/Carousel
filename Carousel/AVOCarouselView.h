//
// Created by Artem Olkov on 11/07/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AVOCarouselView : UIView

@property (strong, nonatomic) NSArray *cells;
@property (assign, nonatomic, readonly) BOOL clockwiseSpin;
@property (assign, nonatomic, readonly) BOOL counterClockwiseSpin;


-(instancetype) initWithFrame:(CGRect)frame;
-(instancetype) initWithCoder:(NSCoder *) aDecoder;


@end