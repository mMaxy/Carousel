//
// Created by Artem Olkov on 11/07/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOCarouselView.h"
#import "AVOPath.h"
#import "AVOSizeCalculator.h"
#import "AVORotator.h"
#import "POPAnimation.h"

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
@property (strong, nonatomic, readonly) AVORotator *rotator;

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

@end

@implementation AVOCarouselView {

}

@synthesize calc = _calc;
@synthesize path = _path;
@synthesize rotator = _rotator;

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
    //TODO: do smth
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
    CGPoint translation = [recognizer translationInView:self];
    CGPoint point = [recognizer locationInView:self];

    CGPoint centerBefore = CGPointMake(point.x - translation.x, point.y - translation.y);
    double startAngle = [self.rotator getAngleFromPoint:centerBefore onFrame:self.frame];
    double endAngle = [self.rotator getAngleFromPoint:point onFrame:self.frame];

    if (startAngle-endAngle > M_PI_2) {
        endAngle += 2 * M_PI;
    }
    if (endAngle-startAngle > M_PI_2) {
        endAngle -= 2 * M_PI;
    }

    double deltaAngle = endAngle - startAngle;

    self.velocity = 0.f;
    self.acceleration = 0.f;

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
//            [self setupScrollTimer];
            self.startOffset = self.cellsOffset;
//            self.panStartTime = CFAbsoluteTimeGetCurrent();
        case UIGestureRecognizerStateChanged: {
//            self.lastChange = CFAbsoluteTimeGetCurrent();

            if (startAngle > endAngle) {
                _spinDirection = AVOSpinCounterClockwise;
            } else if (startAngle < endAngle){
                _spinDirection = AVOSpinClockwise;
            } else {
                _spinDirection = AVOSpinNone;
            }

            NSIndexPath *indexPath = [self.path getCellIndexWithPoint:point];
            if (indexPath == nil || indexPath.item == 8) {
                return;
            }

            self.cellsOffset = self.startOffset + (CGFloat) (deltaAngle);
            if (self.cellsOffset > 2*M_PI)
                self.cellsOffset -= 2*M_PI;
            if (self.cellsOffset < 0.f)
                self.cellsOffset += 2*M_PI;

        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.startOffset = self.cellsOffset;

            double curTime = CFAbsoluteTimeGetCurrent();
//            double timeElapsed = curTime - self.lastChange;
//            double deltaTime = curTime - self.panStartTime;

            if (_spinDirection == AVOSpinNone){
                //There was no spin before, don't scroll
                return;
            }
//            CGPoint velocity = [gestureRecognizer velocityInView:self.collectionView];
//            CGFloat angleVelocity = [self getAngleVelocityFromPoint:point withVectorVelocity:velocity];
//            double angleVelocity = deltaAngle / deltaTime;

//            if ( timeElapsed < 0.2 ) {
//                //set velocity to self
//                self.velocity = angleVelocity;
//                self.acceleration = 1.5f ;
//            } else {
                // there was no scroll
//                self.velocity = 0.f;
//                self.acceleration = 0.f;
//
//                [self moveCellsToPlace];
//            }

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
    [self pop_removeAnimationForKey:@"bounce"];
    [self pop_removeAnimationForKey:@"decelerate"];

    //call delegate to tell him, that view were tapped
    CGPoint point = [recognizer locationInView:self];
    NSIndexPath *indexPath = [self findIndexPathForCellWithPoint:point];
    [self.delegate carouselView:self
           tapOnCellAtIndexPath:indexPath];
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

    CGPoint rotated = [self.rotator rotatedPointFromPoint:p byAngle:remain inFrame:f];

    rotated.y *=  self.railsHeightToWidthRelation;
    rotated.x = rotated.x + self.calc.horizontalInset + self.calc.cellSize.width/2;
    rotated.y = rotated.y + self.calc.verticalInset + self.calc.cellSize.height/2;

    (*center) = CGPointMake(rotated.x , rotated.y);
}

//TODO: move somewhere and refactor without offset
//get angle velocity, given vector and point from that vector starts
- (CGFloat)getAngleVelocityFromPoint:(CGPoint)point withVectorVelocity:(CGPoint)velocity {
    CGFloat x;
    CGFloat y;
    // getting sum of vectors (from frame center to pan ended location with velocity)
    //if (point.y > self.collectionView.frame.size.height)
    velocity.y *= -1;
    x = point.x + velocity.x;
    y = point.y + velocity.y;
    CGPoint delta = CGPointMake(x, y);

    // spin sum vector on offset
    [self moveCenter:&delta byAngle:self.cellsOffset];

    // real velocity is difference between moved sum vector and offset vector
    x = delta.x - ((CGFloat) cos(self.cellsOffset)) * self.rails.size.width/2;
    y = delta.y - ((CGFloat) sin(self.cellsOffset)) * self.rails.size.height/2;

    // setting real velocity vector
    velocity.x = x;
    velocity.y = y;

    //spin velocity vector to be like there is no offset
    // It allows us understand are moving going clockwise or not
    x = (CGFloat) (velocity.x * cos(-self.cellsOffset) + velocity.y * sin(-self.cellsOffset));
    y = (CGFloat) (velocity.y * cos(-self.cellsOffset) - velocity.x * sin(-self.cellsOffset));
    velocity.x = (CGFloat) x;
    velocity.y = (CGFloat) y;

    CGFloat distVelocity = velocity.y;
    //normalized
    distVelocity *= 1/ self.railsHeightToWidthRelation;
    CGFloat railsPerimeter = self.rails.size.width*2 + self.rails.size.height*2;
    CGFloat velocityAsPartOfPerimeter = distVelocity / (railsPerimeter);
    //counting angle velocity. It goes in opposite direction than velocity vector
    CGFloat angleVelocity = (CGFloat) (2 * M_PI * velocityAsPartOfPerimeter);

    if (angleVelocity > 0 && _spinDirection == AVOSpinCounterClockwise) {
        angleVelocity *= -1;
    }
    if (angleVelocity < 0 && _spinDirection == AVOSpinClockwise){
        angleVelocity *= -1;
    }
    return angleVelocity;
}

//TODO: decide, what to do with this method
-(void) moveCellsToPlace {
    double moveToAngle;
    CGFloat current = self.cellsOffset;
    if (current < M_PI_4/2 && current > 0) {
        moveToAngle = 0;
    } else if (current < 3 * M_PI_4/2 && current > M_PI_4/2) {
        moveToAngle = M_PI_4;
    } else if (current < 5 * M_PI_4/2 && current > 3 * M_PI_4/2) {
        moveToAngle = M_PI_2;
    } else if (current < 7 * M_PI_4/2 && current > 5 * M_PI_4/2) {
        moveToAngle = 3*M_PI_4;
    } else if (current < 9 * M_PI_4/2 && current > 7 * M_PI_4/2) {
        moveToAngle = M_PI;
    } else if (current < 11 * M_PI_4/2 && current > 9 * M_PI_4/2) {
        moveToAngle = 5*M_PI_4;
    } else if (current < 13 * M_PI_4/2 && current > 11 * M_PI_4/2) {
        moveToAngle = 3*M_PI_2;
    } else if (current < 15 * M_PI_4/2 && current > 13 * M_PI_4/2) {
        moveToAngle = 7*M_PI_4;
    } else if (current < 16 * M_PI_4/2 && current > 15 * M_PI_4/2) {
        moveToAngle = 2*M_PI;
    } else {
        //offset is already in place
        return;
    }

    double delta = moveToAngle - current;
    double acceleration = 0.7f;
    double velocity = sqrt(2*acceleration*acceleration*fabs(delta));

//    if (velocity > 0) [self setupScrollTimer];

    velocity *= fabs(delta)/delta;
    self.velocity = (CGFloat) velocity;
    self.acceleration = (CGFloat) acceleration;

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

#pragma mark - Setters

- (void)setCells:(NSArray *)cells {
    NSAssert([cells count] == 9, @"This view can handle only 9 cells by design");
    if (_cells) {
        for (UIView *cell in _cells) {
            [cell removeFromSuperview];
        }
    }
    NSUInteger index = 0;
    for (UIView *cell in _cells) {
        //TODO: place cell with default offset
        CGRect frame = [self frameForCardAtIndex:index];

        index ++;
    }
    self.cellsOffset = 0.f;
    _cells = cells;
}


#pragma mark - Private lazy initialization

- (AVOPath *)path {
    if (!_path || !_calc) {
        [self calculateDefaults];
    }
    return _path;
}

- (AVORotator *)rotator {
    if (!_rotator) {
        _rotator = [[AVORotator alloc] init];
    }
    return _rotator;
}


- (AVOSizeCalculator *)calc {
    if (!_path || !_calc) {
        [self calculateDefaults];
    }
    return _calc;
}

@end