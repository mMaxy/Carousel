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
@property (assign, nonatomic) CGFloat velocity;
@property (assign, nonatomic) CGFloat acceleration;
@property (assign, nonatomic) BOOL clockwise;
@property (assign, nonatomic, readonly) double maxCellsOffset;
@property (assign, nonatomic, readonly) CGRect rails;
@property (assign, nonatomic, readonly) CGFloat railsHeightToWidthRelation;

@property (strong, nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

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

    double offsetMax = M_PI * 2;
    _rails = CGRectMake(railXMin, railXMin, railXMax-railXMin, railXMax-railXMin);

    _maxCellsOffset = offsetMax;

    _railsHeightToWidthRelation = (railYMax-railYMin) / (railXMax-railXMin);

    _cellsOffset = 0.f;
    _acceleration = 0.f;
    _velocity = 0.f;

    [self setupScrollTimerClockwise:YES];

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
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [gestureRecognizer translationInView:self.collectionView];
            CGPoint point = [gestureRecognizer locationInView:self.collectionView];

            CGFloat x = point.x - self.sizeCalculator.horizontalInset;
            CGFloat y = point.y - self.sizeCalculator.verticalInset;
            point = CGPointMake(x, y);
            NSIndexPath *indexPath = [self.path getCellIndexWithPoint:point];
            if (indexPath == nil || indexPath.item == 8) {
                return;
            }

            CGPoint centerBefore = [self.path getCenterForIndexPath:indexPath];
            centerBefore.x -= translation.x;
            centerBefore.y -= translation.y;
            centerBefore.x = centerBefore.x - self.sizeCalculator.horizontalInset - self.sizeCalculator.cellSize.width/2;
            centerBefore.y = centerBefore.y - self.sizeCalculator.verticalInset - self.sizeCalculator.cellSize.height/2;
            centerBefore.y *= 1/self.railsHeightToWidthRelation;

            CGPoint centerAfter = [self.path getCenterForIndexPath:indexPath];

            centerAfter.x = centerAfter.x - self.sizeCalculator.horizontalInset - self.sizeCalculator.cellSize.width/2;
            centerAfter.y = centerAfter.y - self.sizeCalculator.verticalInset - self.sizeCalculator.cellSize.height/2;
            centerAfter.y *= 1/self.railsHeightToWidthRelation;

            double startAngle = [self.rotator getAngleFromPoint:centerBefore onFrame:self.rails];
            double endAngle = [self.rotator getAngleFromPoint:centerAfter onFrame:self.rails];

            self.cellsOffset += endAngle-startAngle;

            [self invalidateLayout];
        } break;
        case UIGestureRecognizerStateCancelled:

        case UIGestureRecognizerStateEnded: {
//            CGPoint velocity = [gestureRecognizer velocityInView:self.collectionView];
//
//            if (velocity.x != 0 && velocity.y != 0) {
//
//                self.velocity = velocity;
//            }
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
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self findIndexPathForCellWithPoint:point];
    [self.delegate collectionView:self.collectionView
             tapOnCellAtIndexPath:indexPath];
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

- (CGPoint)getPossibleDirectionFromPoint:(CGPoint)point {
    BOOL leftTopCorner  = point.x == self.rails.origin.x && point.y == self.rails.origin.y;
    BOOL rightTopCorner = point.x == self.rails.origin.x + self.rails.size.width && point.y == self.rails.origin.y;
    BOOL leftBotCorner  = point.x == self.rails.origin.x && point.y == self.rails.origin.y + self.rails.size.height;
    BOOL rightBotCorner = point.x == self.rails.origin.x + self.rails.size.width && point.y == self.rails.origin.y + self.rails.size.height;

    if (leftTopCorner) {
        if (self.clockwise)
            return CGPointMake(1.f, 0.f);
        else
            return CGPointMake(0.f, 1.f);
    }
    if (rightTopCorner) {
        if (self.clockwise)
            return CGPointMake(0.f, 1.f);
        else
            return CGPointMake(-1.f, 0.f);
    }
    if (leftBotCorner) {
        if (self.clockwise)
            return CGPointMake(0.f, -1.f);
        else
            return CGPointMake(1.f, 0.f);
    }
    if (rightBotCorner) {
        if (self.clockwise)
            return CGPointMake(-1.f, 0.f);
        else
            return CGPointMake(0.f, -1.f);
    }

    if (point.x == self.rails.origin.x) {
        return CGPointMake(0.f, _clockwise ? -1.f : 1.f);
    }
    if (point.x == self.rails.origin.x + self.rails.size.width) {
        return CGPointMake(0.f, _clockwise ? 1.f : -1.f);
    }

    if (point.y == self.self.rails.origin.y) {
        return CGPointMake(_clockwise ? 1.f : -1.f, 0.f);
    }
    if (point.y == self.self.rails.origin.y + self.rails.size.height) {
        return CGPointMake(_clockwise ? -1.f : 1.f, 0.f);
    }

    return CGPointZero;
}

- (void)invalidatesScrollTimer {
    if (!self.displayLink.paused) {
        [self.displayLink invalidate];
    }
    self.displayLink = nil;
}

- (void)setupScrollTimerClockwise:(BOOL) clockwise {
    [self invalidatesScrollTimer];
    self.clockwise = clockwise;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleScroll)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)handleScroll {
    _cellsOffset += _velocity;
    if (_cellsOffset >= _maxCellsOffset) {
        _cellsOffset -= _maxCellsOffset;
    }

    _velocity -= _acceleration;

    [super invalidateLayout];

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
