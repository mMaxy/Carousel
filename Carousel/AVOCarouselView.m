//
// Created by Artem Olkov on 11/07/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOCarouselView.h"


@interface AVOCarouselView ()

@property (assign, nonatomic, readwrite) BOOL clockwiseSpin;
@property (assign, nonatomic, readwrite) BOOL counterClockwiseSpin;


- (void)privateInit;


@end

@implementation AVOCarouselView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self privateInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
         [self privateInit];
    }
    return self;
}

- (void)privateInit {

}

- (void)setCells:(NSArray *)cells {
    _cells = cells;
}

@end