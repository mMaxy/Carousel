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
@property (assign, nonatomic) BOOL panActive;

@property (strong, nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation AVOCollectionViewLayout {
    double _lastChange;
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

    _panActive = NO;

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

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            self.panActive = YES;
            self.velocity = 0.f;
            self.acceleration = 0.f;

            _lastChange = CFAbsoluteTimeGetCurrent();
            
            CGFloat x = point.x - self.sizeCalculator.horizontalInset;
            CGFloat y = point.y - self.sizeCalculator.verticalInset;
            point = CGPointMake(x, y);
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
            self.panActive = NO;

            CGPoint velocity = [gestureRecognizer velocityInView:self.collectionView];

            double x = velocity.x * cos(self.cellsOffset) + velocity.y * sin(self.cellsOffset);
            double y = velocity.y * cos(self.cellsOffset) - velocity.x * sin(self.cellsOffset);
            velocity.x = (CGFloat) x;
            velocity.y = (CGFloat) y;

            CGFloat modVel = (CGFloat) sqrt(velocity.x*velocity.x + velocity.y*velocity.y) / 70000;

            double relationalVelocity = modVel / M_PI_4;
            
            double curTime = CFAbsoluteTimeGetCurrent();
            double timeElapsed = curTime - _lastChange;
            if ( timeElapsed < 0.1 )
                self.velocity = (CGFloat) relationalVelocity;
            else
                self.velocity = 0.f;

            if (velocity.y > 0) {
                //clockwise
                self.velocity *= -1;
                self.acceleration = (self.velocity / 100 );
            } else if (velocity.y < 0) {
                //counter clockwise

                self.acceleration = (self.velocity / 100 );
            } else {
                //don't move
                self.acceleration = 0.f;
            }

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
            self.panActive = YES;
            CGPoint point = [gestureRecognizer locationInView:self.collectionView];
            NSIndexPath *indexPath = [self findIndexPathForCellWithPoint:point];
            [self.delegate collectionView:self.collectionView
               longpressOnCellAtIndexPath:indexPath];
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.panActive = NO;
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
    _cellsOffset += _velocity;
    if (_cellsOffset >= _maxCellsOffset) {
        _cellsOffset -= _maxCellsOffset;
    }

    _velocity -= _acceleration;
    BOOL flagStopped = self.velocity <= 0.0005f && self.velocity >= -0.0005f;

    if (flagStopped && !self.panActive) {
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) 0];
        NSIndexPath *resBot;
        CGPoint resDirection;
        CGFloat resDistance;

        //when
        [self moveCenter:&center byAngle:self.cellsOffset];
        resBot = [self.path getNearestCellIndexFromPoint:center
                                     withResultDirection:&resDirection
                                       andResultDistance:&resDistance];
        if (resDistance != 0) {
            double relationalVelocity =(resDistance) /  M_PI_4 * self.sizeCalculator.cellSize.width;
            self.velocity = (CGFloat) (relationalVelocity / 100);
            double x = resDirection.x * cos(self.cellsOffset) + resDirection.y * sin(self.cellsOffset);
            double y = resDirection.y * cos(self.cellsOffset) - resDirection.x * sin(self.cellsOffset);
            resDirection.x = (CGFloat) x;
            resDirection.y = (CGFloat) y;

            if (resDirection.y > 0) {
                //clockwise
                self.velocity *= -1;
            }
            if (resDirection.y != 0) {
                self.acceleration = (self.velocity / 10 );
            } else {
                //don't move
                self.acceleration = 0.f;
            }
        }

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
    CGFloat x = point.x - self.sizeCalculator.horizontalInset;
    CGFloat y = point.y - self.sizeCalculator.verticalInset;
    point = CGPointMake(x, y);
    NSIndexPath *indexPath = [self.path getCellIndexWithPoint:point];
    point.x += self.sizeCalculator.horizontalInset;
    point.y += self.sizeCalculator.verticalInset;
    if (indexPath.item != 8) {
        point = [self.path getCenterForIndexPath:indexPath];

        [self moveCenter:&point byAngle:-self.cellsOffset];
    }
    point.x -= self.sizeCalculator.horizontalInset;
    point.y -= self.sizeCalculator.verticalInset;
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

-(NSArray *) fixedAngles {
    return @[
            @(0), //0
            @(M_PI_4), //45
            @(M_PI_2), //90
            @(M_PI_2 + M_PI_4), //135
            @(2 * M_PI), //180
            @(2*M_PI + M_PI_4), //225
            @(2*M_PI + M_PI_2), //270
            @(2*M_PI + M_PI_2 + M_PI_4), //315
    ];
}

- (id<AVOCollectionViewDelegateLayout>)delegate {
    return (id<AVOCollectionViewDelegateLayout>)self.collectionView.delegate;
}

@end
