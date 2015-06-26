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
@property (assign, nonatomic, readonly) double maxCellsOffset;
@property (assign, nonatomic, readonly) CGRect rails;
@property (assign, nonatomic, readonly) CGFloat railsHeightToWidthRelation;

@property (strong, nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation AVOCollectionViewLayout {
    double _lastChange;
    AVOSpinDirection _spinDirection;
    double _lastFrame;
}

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

    double offsetMax = M_PI * 2;
    _rails = CGRectMake(railXMin, railXMin, railXMax-railXMin, railXMax-railXMin);

    _maxCellsOffset = offsetMax;

    _railsHeightToWidthRelation = (railYMax-railYMin) / (railXMax-railXMin);

    _cellsOffset = 0.f;
    _acceleration = 0.f;
    _velocity = 0.f;

    [self setupScrollTimer];

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
    double startAngle = [self.rotator getAngleFromPoint:centerBefore onFrame:self.collectionView.frame];
    double endAngle = [self.rotator getAngleFromPoint:point onFrame:self.collectionView.frame];

    self.velocity = 0.f;
    self.acceleration = 0.f;

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            _lastChange = CFAbsoluteTimeGetCurrent();

            if (startAngle > endAngle) {
                _spinDirection = AVOSpinClockwise;
            } else if (startAngle < endAngle){
                _spinDirection = AVOSpinCounterClockwise;
            } else {
                _spinDirection = AVOSpinNone;
            }

            NSIndexPath *indexPath = [self.path getCellIndexWithPoint:point];
            if (indexPath == nil || indexPath.item == 8) {
                return;
            }

            self.cellsOffset = self.whilePanCellOffset + (CGFloat) (endAngle-startAngle);
            if (self.cellsOffset > 2*M_PI)
                self.cellsOffset -= 2*M_PI;
            if (self.cellsOffset < 0.f)
                self.cellsOffset += 2*M_PI;

        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.whilePanCellOffset = self.cellsOffset;

            double curTime = CFAbsoluteTimeGetCurrent();
            double timeElapsed = curTime - _lastChange;

            CGFloat x;
            CGFloat y;

            CGPoint velocity = [gestureRecognizer velocityInView:self.collectionView];

            if (_spinDirection == AVOSpinNone){
                //There was no spin before, don't scroll
                return;
            }

            // getting sum of vectors (from frame center to pan ended location with velocity)
//            if (point.y > self.collectionView.frame.size.height)
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
            //normilized
            distVelocity *= 1/self.railsHeightToWidthRelation;
            CGFloat railsPerimeter = self.rails.size.width*2 + self.rails.size.height*2;
            CGFloat velocityAsPartOfPerimeter = distVelocity / (railsPerimeter);
            //counting angle velocity. It goes in opposite direction than velocity vector
            CGFloat angleVelocity = (CGFloat) (2 * M_PI * velocityAsPartOfPerimeter);

            if (angleVelocity < 0 && _spinDirection == AVOSpinCounterClockwise) {
                angleVelocity *= -1;
            }
            if (angleVelocity > 0 && _spinDirection == AVOSpinClockwise){
                angleVelocity *= -1;
            }

            if ( timeElapsed < 0.2 ) {
                //set velocity to self
                self.velocity = angleVelocity;
            } else {
                // there was no scroll
                self.velocity = 0.f;
                self.acceleration = 0.f;
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
            self.velocity = 0.f;
            self.acceleration = 0.f;
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
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self findIndexPathForCellWithPoint:point];
    [self.delegate collectionView:self.collectionView
             tapOnCellAtIndexPath:indexPath];
}

- (void) handleTimer {
    double curTime = CFAbsoluteTimeGetCurrent();
    double timeElapsed = curTime - _lastFrame;
    _lastFrame = curTime;


    _cellsOffset += _velocity * (timeElapsed);
    if (_cellsOffset >= _maxCellsOffset) {
        _cellsOffset -= _maxCellsOffset;
    }

    _velocity -= _acceleration * (timeElapsed);
    if (self.velocity <= 0.005f && self.velocity >= -0.005f ) {
        _velocity = 0.f;
        _acceleration = 0.f;
    }
    [super invalidateLayout];

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

- (void)invalidateLayout {
    if (self.collectionView.bounds.size.height != self.sizeCalculator.frameSize.height || self.collectionView.bounds.size.width != self.sizeCalculator.frameSize.width) {
        _path = nil;
        _sizeCalculator = nil;
    }
    [super invalidateLayout];
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

    CGPoint rotated = [self.rotator rotatedPointFromPoint:p byAngle:remain inFrame:f];

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
