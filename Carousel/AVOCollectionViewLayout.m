//
//  AVOCollectionViewLayout.m
//  Carousel
//
//  Created by Artem Olkov on 21/06/15.
//  Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOCollectionViewLayout.h"
#import "AVOSizeCalculator.h"
#import "AVOPath.h"
#import "AVORotator.h"

typedef NS_ENUM(NSInteger, AVOSpinDirection) {
    AVOSpinNone = 0,
    AVOSpinClockwise,
    AVOSpinCounterClockwise
};

@interface AVOCollectionViewLayout () <UIGestureRecognizerDelegate>

@property (strong, nonatomic, readonly) AVOSizeCalculator *sizeCalculator;
@property (strong, nonatomic, readonly) AVOPath *path;
@property (strong, nonatomic, readonly) AVORotator *rotator;

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) CGFloat cellsOffset;
@property (assign, nonatomic) CGFloat whilePanCellOffset;
@property (assign, nonatomic) CGFloat velocity;
@property (assign, nonatomic) CGFloat acceleration;
@property (assign, nonatomic, readonly) CGFloat maxCellsOffset;
@property (assign, nonatomic, readonly) CGRect rails;
@property (assign, nonatomic, readonly) CGFloat railsHeightToWidthRelation;

@property (strong, nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

@property(nonatomic) AVOSpinDirection spinDirection;

@property(assign, nonatomic) double lastChange;
@property(assign, nonatomic) double panStartTime;

@end

@implementation AVOCollectionViewLayout

@synthesize sizeCalculator = _sizeCalculator;
@synthesize path = _path;
@synthesize rotator = _rotator;

- (void)calculateDefaults {
    _sizeCalculator = [[AVOSizeCalculator alloc] init];
    _path = [[AVOPath alloc] init];

    [self.sizeCalculator setRectToFit:self.collectionView.frame];
    [self.path setSizeCalculator:self.sizeCalculator];

    [self invalidatesScrollTimer];

    CGFloat railYMin = [self.path getCenterForIndex:2].y;
    CGFloat railYMax = [self.path getCenterForIndex:4].y;
    CGFloat railXMin = [self.path getCenterForIndex:0].x;
    CGFloat railXMax = [self.path getCenterForIndex:2].x;

    CGFloat offsetMax = (CGFloat) (M_PI * 2);
    _rails = CGRectMake(railXMin, railXMin, railXMax-railXMin, railXMax-railXMin);

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
    [self.collectionView addGestureRecognizer:_tapGestureRecognizer];

    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleLongPressGesture:)];
    _longPressGestureRecognizer.delegate = self;

    [self.collectionView addGestureRecognizer:_longPressGestureRecognizer];

    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handlePanGesture:)];
    _panGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:_panGestureRecognizer];
}

#pragma mark Tap Handlers

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:self.collectionView];
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];

    CGPoint centerBefore = CGPointMake(point.x - translation.x, point.y - translation.y);
    double startAngle = [AVORotator getAngleFromPoint:centerBefore onFrame:self.collectionView.frame];
    double endAngle = [AVORotator getAngleFromPoint:point onFrame:self.collectionView.frame];

    if (startAngle-endAngle > M_PI_2) {
        endAngle += 2 * M_PI;
    }
    if (endAngle-startAngle > M_PI_2) {
        endAngle -= 2 * M_PI;
    }

    double deltaAngle = endAngle - startAngle;

    self.velocity = 0.f;
    self.acceleration = 0.f;

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self setupScrollTimer];
            self.whilePanCellOffset = self.cellsOffset;
            self.panStartTime = CFAbsoluteTimeGetCurrent();
        case UIGestureRecognizerStateChanged: {
            self.lastChange = CFAbsoluteTimeGetCurrent();

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

            self.cellsOffset = self.whilePanCellOffset + (CGFloat) (deltaAngle);
            if (self.cellsOffset > 2*M_PI)
                self.cellsOffset -= 2*M_PI;
            if (self.cellsOffset < 0.f)
                self.cellsOffset += 2*M_PI;

        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.whilePanCellOffset = self.cellsOffset;

            double curTime = CFAbsoluteTimeGetCurrent();
            double timeElapsed = curTime - self.lastChange;
            double deltaTime = curTime - self.panStartTime;

            if (_spinDirection == AVOSpinNone){
                //There was no spin before, don't scroll
                return;
            }
//            CGPoint velocity = [gestureRecognizer velocityInView:self.collectionView];
//            CGFloat angleVelocity = [self getAngleVelocityFromPoint:point withVectorVelocity:velocity];
            double angleVelocity = deltaAngle / deltaTime;

            if ( timeElapsed < 0.2 ) {
                //set velocity to self
                self.velocity = angleVelocity;
                self.acceleration = 1.5f ;
            } else {
                // there was no scroll
                self.velocity = 0.f;
                self.acceleration = 0.f;
                [self invalidatesScrollTimer];
                [self moveCellsToPlace];
            }

            _spinDirection = AVOSpinNone;
        } break;
        default: {
            // Do nothing...
        } break;
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch(gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint point = [gestureRecognizer locationInView:self.collectionView];
            NSIndexPath *indexPath = [self findIndexPathForCellWithPoint:point];
            [self.delegate collectionView:self.collectionView
               longpressOnCellAtIndexPath:indexPath];
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGPoint point = [gestureRecognizer locationInView:self.collectionView];
            NSIndexPath *indexPath = [self findIndexPathForCellWithPoint:point];
            [self.delegate collectionView:self.collectionView
                    liftOnCellAtIndexPath:indexPath];
        } break;

        default: break;
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    self.velocity = 0.f;
    self.acceleration = 0.f;
    [self invalidatesScrollTimer];
    [self moveCellsToPlace];
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self findIndexPathForCellWithPoint:point];
    [self.delegate collectionView:self.collectionView
             tapOnCellAtIndexPath:indexPath];
}

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

    if (velocity > 0) [self setupScrollTimer];

    velocity *= fabs(delta)/delta;
    self.velocity = (CGFloat) velocity;
    self.acceleration = (CGFloat) acceleration;

}

#pragma mark - UICollectionViewLayout Implementation

- (CGSize)collectionViewContentSize {
    // Don't scroll horizontally
    CGFloat contentWidth = self.collectionView.bounds.size.width;

    // Don't scroll vertically
    CGFloat contentHeight = self.collectionView.bounds.size.height;

    CGSize contentSize = CGSizeMake(contentWidth, contentHeight);
    return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray array];

    // Cells
    NSArray *visibleIndexPaths = [self indexPathsOfItemsInRect:rect];
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [layoutAttributes addObject:attributes];
    }

    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    CGRect frame = [self frameForCardAtIndex:(NSUInteger) indexPath.item];
    attributes.frame = frame;

    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

#pragma mark - Helpers

- (NSArray *)indexPathsOfItemsInRect:(CGRect)rect {
    NSArray *indexPaths;

    indexPaths = [self.path getIndexesInRect:rect];

    return indexPaths;
}

- (CGRect)frameForCardAtIndex:(NSUInteger) index {
    CGRect frame = CGRectZero;

    frame.size = [self.sizeCalculator cellSize];
    CGPoint center = [self.path getCenterForIndex:index];
    if (index != 8) {
        [self moveCenter:&center byAngle:self.cellsOffset];
    }

    frame.origin = CGPointMake(center.x - frame.size.width/2, center.y - frame.size.height/2);

    return frame;
}

- (void)moveCenter:(CGPoint *)center byAngle:(double) angle {
    CGPoint p = (*center);
    double remain = angle;

    CGRect f = self.rails;

    p.x = p.x - self.sizeCalculator.horizontalInset - self.sizeCalculator.cellSize.width/2;
    p.y = p.y - self.sizeCalculator.verticalInset - self.sizeCalculator.cellSize.height/2;
    p.y *= 1/self.railsHeightToWidthRelation;

    CGPoint rotated = [AVORotator rotatedPointFromPoint:p byAngle:remain inFrame:f];

    rotated.y *=  self.railsHeightToWidthRelation;
    rotated.x = rotated.x + self.sizeCalculator.horizontalInset + self.sizeCalculator.cellSize.width/2;
    rotated.y = rotated.y + self.sizeCalculator.verticalInset + self.sizeCalculator.cellSize.height/2;

    (*center) = CGPointMake(rotated.x , rotated.y);
}

- (void)invalidatesScrollTimer {
    if (!self.displayLink.paused) {
        [self.displayLink invalidate];
    }
    self.displayLink = nil;
}

- (void)setupScrollTimer {
    [self invalidatesScrollTimer];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleTimer)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (NSIndexPath *)findIndexPathForCellWithPoint:(CGPoint)point {
    NSIndexPath *indexPath = [self.path getCellIndexWithPoint:point];
    if (indexPath.item != 8) {
        point = [self.path getCenterForIndexPath:indexPath];

        [self moveCenter:&point byAngle:-self.cellsOffset];
    }
    indexPath = [self.path getCellIndexWithPoint:point];
    return indexPath;
}

#pragma mark Getters and Setters

- (AVOPath *)path {
    if (!_path || !_sizeCalculator) {
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


- (AVOSizeCalculator *)sizeCalculator {
    if (!_path || !_sizeCalculator) {
        [self calculateDefaults];
    }
    return _sizeCalculator;
}

- (id<AVOCollectionViewDelegateLayout>)delegate {
    return (id<AVOCollectionViewDelegateLayout>)self.collectionView.delegate;
}

@end
