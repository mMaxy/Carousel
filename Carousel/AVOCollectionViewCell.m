//
//  AVOCollectionViewCell.m
//  Carousel
//
//  Created by Artem Olkov on 20/06/15.
//  Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOCollectionViewCell.h"

@implementation AVOCollectionViewCell

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    [self setBackgroundColor:[UIColor redColor]];
}

@end
