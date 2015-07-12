//
// Created by Artem Olkov on 11/07/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOCarouselView.h"
#import "AVOPath.h"
#import "AVOSizeCalculator.h"
#import "AVOGeometryCalculations.h"
#import "POPAnimation.h"
#import "POPAnimatableProperty.h"
#import "POPDecayAnimation.h"
#import "POPSpringAnimation.h"

typedef NS_ENUM(NSInteger, AVOSpinDirection) {
    AVOSpinNone = 0,
    AVOSpinClockwise,
    AVOSpinCounterClockwise
};

const float kAVOCarouselDecelerationValue = 0.998f;
const float kAVOCarouselVelocityValue = 0.2f;
NSString *const kAVOCarouselViewDecayAnimationName = @"AVOCarouselViewDecay";

@interface AVOCarouselView () <UIGestureRecognizerDelegate, POPAnimationDelegate>

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


- (void)calculateDefaults;
- (void)setupTouches;
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer;
- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer;
- (void)animateDacayWithVelocity:(CGPoint)velocity;
- (void)animateScrollToOffset:(CGFloat)offset;
- (double)countDeltaAngleToPoint:(CGPoint)translation fromPoint:(CGPoint)point;
- (CGFloat)countAngleVelocityFromVectorVelocity:(CGPoint)velocity;
- (void)moveCellsToPlace;
- (void)stopAnimations;
- (void)placeCells;
- (POPAnimatableProperty *)cellsOffsetProperty;

@end

@implementation AVOCarouselView {

}

@synthesize calc = _calc;
@synthesize path = _path;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self calculateDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
         [self calculateDefaults];
    }
    return self;
}

- (void)calculateDefaults {
    _calc = [[AVOSizeCalculator alloc] init];
    _path = [[AVOPath alloc] init];

    [self.calc setRectToFit:self.frame];
    [self.path setSizeCalculator:self.calc];

    [self pop_removeAnimationForKey:@"bounce"];
    [self pop_removeAnimationForKey:@"decelerate"];

    CGFloat offsetMax = (CGFloat) (M_PI * 2);

    _maxCellsOffset = offsetMax;
    _cellsOffset = 0.f;

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

            double deltaAngle = [self countDeltaAngleToPoint:translation fromPoint:point];

            NSIndexPath *indexPath = [self.path findCellIndexWithPoint:point];
            if (indexPath == nil || indexPath.item == 8) {
                return;
            }

            //TODO: delete
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

            [self animateDacayWithVelocity:velocity];

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
            NSIndexPath *indexPath = [self.path findIndexPathForCellWithPoint:point withOffset:self.cellsOffset];
            [self.delegate carouselView:self longpressOnCellAtIndexPath:indexPath];
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGPoint point = [recognizer locationInView:self];
            NSIndexPath *indexPath = [self.path findIndexPathForCellWithPoint:point withOffset:self.cellsOffset];
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
    NSIndexPath *indexPath = [self.path findIndexPathForCellWithPoint:point withOffset:self.cellsOffset];
    [self.delegate carouselView:self
           tapOnCellAtIndexPath:indexPath];

    [self moveCellsToPlace];
}

#pragma mark - Helpers

- (void)animateDacayWithVelocity:(CGPoint)velocity {
    CGFloat angleVelocity = [self countAngleVelocityFromVectorVelocity:velocity];

    POPDecayAnimation *decayAnimation = [POPDecayAnimation animation];
    decayAnimation.property = [self cellsOffsetProperty];
    decayAnimation.velocity = @(angleVelocity);
    decayAnimation.deceleration = kAVOCarouselDecelerationValue;
    decayAnimation.name = kAVOCarouselViewDecayAnimationName;
    decayAnimation.delegate = self;
    [self pop_addAnimation:decayAnimation forKey:@"decelerate"];
}

- (void)animateScrollToOffset:(CGFloat)offset {
    NSLog(@"%f", offset);
    POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
    springAnimation.property = [self cellsOffsetProperty];
    springAnimation.velocity = @(kAVOCarouselVelocityValue);
    springAnimation.toValue = @(offset);
    [self pop_addAnimation:springAnimation forKey:@"bounce"];
}

- (double)countDeltaAngleToPoint:(CGPoint)translation fromPoint:(CGPoint)point {
    CGPoint centerBefore = CGPointMake(point.x - translation.x, point.y - translation.y);
    double startAngle = [AVOGeometryCalculations countAngleFromPoint:centerBefore onFrame:self.frame];
    CGFloat endAngle = [AVOGeometryCalculations countAngleFromPoint:point onFrame:self.frame];

    if (startAngle-endAngle > M_PI) {
        endAngle += 2 * M_PI;
    }
    if (endAngle-startAngle > M_PI) {
        endAngle -= 2 * M_PI;
    }

    double deltaAngle = endAngle - startAngle;
    return deltaAngle;
}

//get angle velocity, given vector and point from that vector starts
- (CGFloat)countAngleVelocityFromVectorVelocity:(CGPoint)velocity {
    CGFloat angleVelocity = (CGFloat) sqrtf(velocity.x*velocity.x + velocity.y*velocity.y) / self.path.rails.size.width/2;

    if (angleVelocity > 0 && _spinDirection == AVOSpinCounterClockwise) {
        angleVelocity *= -1;
    }
    if (angleVelocity < 0 && _spinDirection == AVOSpinClockwise){
        angleVelocity *= -1;
    }
    return angleVelocity;
}

-(void) moveCellsToPlace {
    CGFloat moveToAngle = [self.path findNearestFixedPositionFrom:self.cellsOffset];
    [self animateScrollToOffset:moveToAngle];
}

- (void)stopAnimations {
    [self pop_removeAnimationForKey:@"bounce"];
    [self pop_removeAnimationForKey:@"decelerate"];
}

- (void)placeCells {
    NSUInteger index = 0;
    for (UIView *cell in _cells) {
        CGRect frame = [self.path frameForCardAtIndex:index withOffset:self.cellsOffset];
        [cell setFrame:frame];
        [self addSubview:cell];
        index ++;
    }
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

#pragma mark - Pop property

- (POPAnimatableProperty *)cellsOffsetProperty {
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

#pragma mark - <POPAnimationDelegate>

- (void)pop_animationDidStop:(POPAnimation *)popAnimation finished:(BOOL)finished {
    if ([popAnimation.name isEqualToString:kAVOCarouselViewDecayAnimationName] && finished) {
        [self moveCellsToPlace];
    }
}

@end