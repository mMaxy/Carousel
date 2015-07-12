//
// Created by Artem Olkov on 11/07/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AVOCarouselView;

FOUNDATION_EXPORT const float kAVOCarouselDecelerationValue;
FOUNDATION_EXPORT const float kAVOCarouselVelocityValue;
FOUNDATION_EXPORT NSString *const kAVOCarouselViewDecayAnimationName;


@protocol AVOCarouselViewDelegate

@optional

- (void)carouselView:(AVOCarouselView *)collectionView tapOnCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)carouselView:(AVOCarouselView *)collectionView longpressOnCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)carouselView:(AVOCarouselView *)collectionView liftOnCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface AVOCarouselView : UIView

@property (strong, nonatomic) NSArray *cells;
@property (assign, nonatomic) id<AVOCarouselViewDelegate> delegate;

-(instancetype) initWithFrame:(CGRect)frame;
-(instancetype) initWithCoder:(NSCoder *) aDecoder;


@end