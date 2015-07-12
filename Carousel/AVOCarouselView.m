//
// Created by Artem Olkov on 11/07/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOCarouselView.h"
#import "AVOPath.h"
#import "AVOSizeCalculator.h"
#import "AVORotator.h"
#import "POPAnimation.h"
#import "POPAnimatableProperty.h"
#import "POPDecayAnimation.h"
#import "POPSpringAnimation.h"

typedef NS_ENUM(NSInteger, AVOSpinDirection) {
    AVOSpinNone = 0,
    AVOSpinClockwise,
    AVOSpinCounterClockwise
};

@interface AVOCarouselView () <UIGestureRecognizerDelegate>

//Direction of spin
@property(assign, nonatomic, readwrite) AVOSpinDirection spinDirection;

//helpers
@property (strong, nonatomic, readonly) AVOPath *path;
@property (strong, nonatomic, readonly) AVOSizeCalculator *calc;

//Cells offsets, define angle by which inner views are moved
@property (assign, nonatomic, readwrite) CGFloat cellsOffset;
@property (assign, nonatomic, readonly) CGFloat maxCellsOffset;
@property (assign, nonatomic, readwrite) CGFloat startOffset;

//gesture recognizers
@property (strong, nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

//TODO: decide, how necessary are these
@property (assign, nonatomic, readwrite) CGFloat velocity;
@property (assign, nonatomic, readwrite) CGFloat acceleration;

//TODO: move to path
@property (assign, nonatomic, readonly) CGRect rails;
@property (assign, nonatomic, readonly) CGFloat railsHeightToWidthRelation;

- (void)privateInit;

- (void)stopAnimations;
@end

@implementation AVOCarouselView {

}

@synthesize calc = _calc;
@synthesize path = _path;

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
    [self calculateDefaults];
}

- (void)calculateDefaults {
    _calc = [[AVOSizeCalculator alloc] init];
    _path = [[AVOPath alloc] init];

    [self.calc setRectToFit:self.frame];
    [self.path setSizeCalculator:self.calc];

    [self pop_removeAnimationForKey:@"bounce"];
    [self pop_removeAnimationForKey:@"decelerate"];

    CGFloat offsetMax = (CGFloat) (M_PI * 2);

    //TODO: move to path
    CGFloat railYMin = [self.path getCenterForIndex:2].y;
    CGFloat railYMax = [self.path getCenterForIndex:4].y;
    CGFloat railXMin = [self.path getCenterForIndex:0].x;
    CGFloat railXMax = [self.path getCenterForIndex:2].x;
    _rails = CGRectMake(railXMin, railXMin, railXMax-railXMin, railXMax-railXMin);
    //end of todo


    _maxCellsOffset = offsetMax;

    _railsHeightToWidthRelation = (railYMax-railYMin) / (railXMax-railXMin);

    _cellsOffset = 0.f;
    _acceleration = 0.f;
    _velocity = 0.f;

    [self setupTouches];
}

- (void)setupTouches {
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    _tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_tapGestureRecognizer];

    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleLongPressGesture:)];
    _longPressGestureRecognizer.delegate = self;

    [self addGestureRecognizer:_longPressGestureRecognizer];

    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handlePanGesture:)];
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
}

//handle Pan
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {


    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self stopAnimations];
            self.startOffset = self.cellsOffset;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:self];
            CGPoint point = [recognizer locationInView:self];
            CGPoint centerBefore = CGPointMake(point.x - translation.x, point.y - translation.y);
            double startAngle = [AVORotator getAngleFromPoint:centerBefore onFrame:self.frame];
            CGFloat endAngle = [AVORotator getAngleFromPoint:point onFrame:self.frame];

//            self.cellsOffset = endAngle;
            if (startAngle-endAngle > M_PI) {
                endAngle += 2 * M_PI;
            }
            if (endAngle-startAngle > M_PI) {
                endAngle -= 2 * M_PI;
            }
            NSLog(@"State Changed with start Angle %f  and End Angle %f", startAngle, endAngle);

            NSIndexPath *indexPath = [self.path getCellIndexWithPoint:point];
            if (indexPath == nil || indexPath.item == 8) {
                return;
            }

            double deltaAngle = endAngle - startAngle;

            if ( deltaAngle < 0) {
                _spinDirection = AVOSpinCounterClockwise;
            } else if (deltaAngle > 0){
                _spinDirection = AVOSpinClockwise;
            } else {
                _spinDirection = AVOSpinNone;
            }

            self.cellsOffset = self.startOffset + (CGFloat) (deltaAngle);

        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGPoint velocity = [recognizer velocityInView:self];
            CGPoint point = [recognizer locationInView:self];

            NSLog(@"Pan ended with velocity: %@", NSStringFromCGPoint(velocity));
            CGFloat angleVelocity = [self getAngleVelocityFromPoint:point withVectorVelocity:velocity];
            NSLog(@"Result angle velocity: %f", angleVelocity);

            POPDecayAnimation *decayAnimation = [POPDecayAnimation animation];
            decayAnimation.property = [self boundsOriginProperty];
            decayAnimation.velocity = @(angleVelocity);
            decayAnimation.deceleration = 0.999f;
            [self pop_addAnimation:decayAnimation forKey:@"decelerate"];

            _spinDirection = AVOSpinNone;
        } break;
        default: {
            // Do nothing...
        } break;
    }
}

//handle Long Tap
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    switch(recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint point = [recognizer locationInView:self];
            NSIndexPath *indexPath = [self findIndexPathForCellWithPoint:point];
            [self.delegate carouselView:self longpressOnCellAtIndexPath:indexPath];
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGPoint point = [recognizer locationInView:self];
            NSIndexPath *indexPath = [self findIndexPathForCellWithPoint:point];
            [self.delegate carouselView:self liftOnCellAtIndexPath:indexPath];
        } break;

        default: break;
    }
}

//Handle tap
- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    //stop animation
    [self stopAnimations];

    //call delegate to tell him, that view were tapped
    CGPoint point = [recognizer locationInView:self];
    NSIndexPath *indexPath = [self findIndexPathForCellWithPoint:point];
    [self.delegate carouselView:self
           tapOnCellAtIndexPath:indexPath];

    //TODO: test, remove it

    [self moveCellsToPlace];
}

- (void)animateScrollToOffset:(CGFloat)offset {
    NSLog(@"%f", offset);
    POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
    springAnimation.property = [self boundsOriginProperty];
    springAnimation.velocity = @(0.3f);
    springAnimation.toValue = @(offset);
    springAnimation.springBounciness = 0.0;
    springAnimation.springSpeed = 5.0;
    [self pop_addAnimation:springAnimation forKey:@"bounce"];
}

//TODO: move to path(or somewhere else)
- (NSIndexPath *)findIndexPathForCellWithPoint:(CGPoint)point {
    NSIndexPath *indexPath = [self.path getCellIndexWithPoint:point];
    if (indexPath.item != 8) {
        point = [self.path getCenterForIndexPath:indexPath];

        [self moveCenter:&point byAngle:-self.cellsOffset];
    }
    indexPath = [self.path getCellIndexWithPoint:point];
    return indexPath;
}

//TODO: move somewhere
- (void)moveCenter:(CGPoint *)center byAngle:(double) angle {
    CGPoint p = (*center);
    double remain = angle;

    CGRect f = self.rails;

    p.x = p.x - self.calc.horizontalInset - self.calc.cellSize.width/2;
    p.y = p.y - self.calc.verticalInset - self.calc.cellSize.height/2;
    p.y *= 1/self.railsHeightToWidthRelation;

    CGPoint rotated = [AVORotator rotatedPointFromPoint:p byAngle:remain inFrame:f];

    rotated.y *=  self.railsHeightToWidthRelation;
    rotated.x = rotated.x + self.calc.horizontalInset + self.calc.cellSize.width/2;
    rotated.y = rotated.y + self.calc.verticalInset + self.calc.cellSize.height/2;

    (*center) = CGPointMake(rotated.x , rotated.y);
}

//TODO: move somewhere and refactor without offset
//get angle velocity, given vector and point from that vector starts
- (CGFloat)getAngleVelocityFromPoint:(CGPoint)point withVectorVelocity:(CGPoint)velocity {
//    CGFloat angle = (CGFloat) [AVORotator getAngleFromPoint:point onFrame:self.frame];
//
//    CGRect tmpFrame = CGRectMake(0.f, 0.f, 2*fmaxf(fabsf(velocity.x), fabsf(velocity.y)), 2*fmaxf(fabsf(velocity.x), fabsf(velocity.y)));
//    velocity.x += fmaxf(fabsf(velocity.x), fabsf(velocity.y));
//    velocity.y += fmaxf(fabsf(velocity.x), fabsf(velocity.y));
//
//    velocity = [AVORotator rotatedPointFromPoint:velocity byAngle:angle inFrame:tmpFrame];
//
//    CGFloat distVelocity = velocity.y;//
    CGFloat distVelocity;// = velocity.y;
    //normalized
//    distVelocity *= 1/self.railsHeightToWidthRelation;
//    CGFloat railsPerimeter = self.rails.size.width*2 + self.rails.size.height*2;
//    distVelocity =
//    CGFloat velocityAsPartOfPerimeter = distVelocity / (railsPerimeter);

    CGFloat angleVelocity = (CGFloat) sqrtf(velocity.x*velocity.x + velocity.y*velocity.y) / self.rails.size.width/2;

    if (angleVelocity > 0 && _spinDirection == AVOSpinCounterClockwise) {
        angleVelocity *= -1;
    }
    if (angleVelocity < 0 && _spinDirection == AVOSpinClockwise){
        angleVelocity *= -1;
    }
    return angleVelocity;
}

-(void) moveCellsToPlace {
    CGFloat moveToAngle = [self getNearestFixedPositionFrom:self.cellsOffset];
    [self animateScrollToOffset:moveToAngle];
}

//TODO: decide, what to do with this method
- (CGFloat)getNearestFixedPositionFrom:(CGFloat)currentPosition {
    CGFloat moveToAngle = currentPosition;
    if (currentPosition < M_PI_4/2 && currentPosition > 0) {
        moveToAngle = 0;
    } else if (currentPosition < 3 * M_PI_4/2 && currentPosition > M_PI_4/2) {
        moveToAngle = (CGFloat) M_PI_4;
    } else if (currentPosition < 5 * M_PI_4/2 && currentPosition > 3 * M_PI_4/2) {
        moveToAngle = (CGFloat) M_PI_2;
    } else if (currentPosition < 7 * M_PI_4/2 && currentPosition > 5 * M_PI_4/2) {
        moveToAngle = (CGFloat) (3*M_PI_4);
    } else if (currentPosition < 9 * M_PI_4/2 && currentPosition > 7 * M_PI_4/2) {
        moveToAngle = (CGFloat) M_PI;
    } else if (currentPosition < 11 * M_PI_4/2 && currentPosition > 9 * M_PI_4/2) {
        moveToAngle = (CGFloat) (5*M_PI_4);
    } else if (currentPosition < 13 * M_PI_4/2 && currentPosition > 11 * M_PI_4/2) {
        moveToAngle = (CGFloat) (3*M_PI_2);
    } else if (currentPosition < 15 * M_PI_4/2 && currentPosition > 13 * M_PI_4/2) {
        moveToAngle = (CGFloat) (7*M_PI_4);
    } else if (currentPosition < 16 * M_PI_4/2 && currentPosition > 15 * M_PI_4/2) {
        moveToAngle = (CGFloat) (2*M_PI);
    }
    return moveToAngle;
}

//TODO:
- (CGRect)frameForCardAtIndex:(NSUInteger) index {
    CGRect frame = CGRectZero;

    frame.size = [self.calc cellSize];
    CGPoint center = [self.path getCenterForIndex:index];
    if (index != 8) {
        [self moveCenter:&center byAngle:self.cellsOffset];
    }

    frame.origin = CGPointMake(center.x - frame.size.width/2, center.y - frame.size.height/2);

    return frame;
}

- (void)stopAnimations {
    [self pop_removeAnimationForKey:@"bounce"];
    [self pop_removeAnimationForKey:@"decelerate"];
}

#pragma mark - Setters

- (void)setCells:(NSArray *)cells {
    NSAssert([cells count] == 9, @"This view can handle only 9 cells by design");
    for (id cell in cells) {
        NSAssert([[cell class] isSubclassOfClass:[UIView class]], @"Cell must be subclass of UIView");
    }
    if (_cells) {
        for (UIView *cell in _cells) {
            [cell removeFromSuperview];
        }
    }

    [self stopAnimations];

    _cells = cells;
    [self placeCells];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self calculateDefaults];
    [self placeCells];

}

- (void)placeCells {
    NSUInteger index = 0;
    for (UIView *cell in _cells) {
        CGRect frame = [self frameForCardAtIndex:index];
        [cell setFrame:frame];
        [self addSubview:cell];
        index ++;
    }
}

#pragma mark - Private lazy initialization

- (AVOPath *)path {
    if (!_path || !_calc) {
        [self calculateDefaults];
    }
    return _path;
}

- (AVOSizeCalculator *)calc {
    if (!_path || !_calc) {
        [self calculateDefaults];
    }
    return _calc;
}

- (void)setCellsOffset:(CGFloat)cellsOffset {
    _cellsOffset = cellsOffset;
    if (_cellsOffset > _maxCellsOffset) {
        _cellsOffset -= _maxCellsOffset;
    }
    if (_cellsOffset < 0) {
        _cellsOffset += _maxCellsOffset;
    }
    [self placeCells];
}

- (POPAnimatableProperty *)boundsOriginProperty {
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"com.artolkov.carousel.cellsOffset"
                                                              initializer:^(POPMutableAnimatableProperty *local_prop) {
                                                                  // read value
                                                                  local_prop.readBlock = ^(id obj, CGFloat values[]) {
                                                                      values[0] = [obj cellsOffset];
                                                                  };
                                                                  // write value
                                                                  local_prop.writeBlock = ^(id obj, const CGFloat values[]) {
                                                                      [obj setCellsOffset:values[0]];
                                                                  };
                                                                  // dynamics threshold
                                                                  local_prop.threshold = 0.01;
                                                              }];

    return prop;
}

@end