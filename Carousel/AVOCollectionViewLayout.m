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

@interface AVOCollectionViewLayout ()

@property (strong, nonatomic, readonly) AVOSizeCalculator *sizeCalculator;
@property (strong, nonatomic, readonly) AVOPath *path;

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) CGFloat cellsOffset;
@property (assign, nonatomic) CGFloat velocity;
@property (assign, nonatomic) CGFloat acceleration;
@property (assign, nonatomic) BOOL clockwise;
@property (assign, nonatomic, readonly) CGFloat maxCellsOffset;
@property (assign, nonatomic, readonly) CGFloat railXMin;
@property (assign, nonatomic, readonly) CGFloat railXMax;
@property (assign, nonatomic, readonly) CGFloat railYMin;
@property (assign, nonatomic, readonly) CGFloat railYMax;

@end

@implementation AVOCollectionViewLayout

@synthesize sizeCalculator = _sizeCalculator;
@synthesize path = _path;

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
        [self moveCenter:&center];
    }

    frame.origin = CGPointMake(center.x - frame.size.width/2, center.y - frame.size.height/2);

    return frame;
}

- (void)moveCenter:(CGPoint *)center {
    CGFloat newX = (*center).x;
    CGFloat newY = (*center).y;
    CGFloat remain = self.cellsOffset;

    while (remain > 0.f) {
        if (self.clockwise) {
            newX += remain;
            remain = 0.f;
            if (newX > self.railXMax) {
                remain += newX - self.railXMax;
                newX = self.railXMax;
            }
            newY += remain;
            remain = 0.f;
            if (newY > self.railYMax) {
                remain += newY - self.railYMax;
                newY = self.railYMax;
            }
            newX -= remain;
            remain = 0.f;
            if (newX < self.railXMin) {
                remain += self.railXMin - newX;
                newX = self.railXMin;
            }
            newY -= remain;
            remain = 0.f;
            if (newY < self.railYMin) {
                remain += self.railYMin - newY;
                newY = self.railYMin;
            }
        } else {
            newX -= remain;
            remain = 0.f;
            if (newX < self.railXMin) {
                remain += self.railXMin - newX;
                newX = self.railXMin;
            }
            newY += remain;
            remain = 0.f;
            if (newY > self.railYMax) {
                remain += newY - self.railYMax;
                newY = self.railYMax;
            }
            newX += remain;
            remain = 0.f;
            if (newX > self.railXMax) {
                remain += newX - self.railXMax;
                newX = self.railXMax;
            }
            newY -= remain;
            remain = 0.f;
            if (newY < self.railYMin) {
                remain += self.railYMin - newY;
                newY = self.railYMin;
            }
        }
    }

    (*center).x = newX;
    (*center).y = newY;
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

- (void)calculateDefaults {
    _sizeCalculator = [[AVOSizeCalculator alloc] init];
    _path = [[AVOPath alloc] init];

    [self.sizeCalculator setRectToFit:self.collectionView.frame];
    [self.path setSizeCalculator:self.sizeCalculator];

    [self invalidatesScrollTimer];

    _railYMin = [self.path getCenterForIndex:2].y;
    _railYMax = [self.path getCenterForIndex:4].y;
    _railXMin = [self.path getCenterForIndex:0].x;
    _railXMax = [self.path getCenterForIndex:2].x;

    CGFloat offsetMax = 0.f;
    offsetMax += 2 * self.railXMax - self.railXMin;
    offsetMax += 2 * self.railYMax - self.railYMin;

    _maxCellsOffset = offsetMax;

    _cellsOffset = 0.f;
    _acceleration = 0.f;
    _velocity = 2.f;

    [self setupScrollTimerClockwise:YES];
}


#pragma mark Getters and Setters

- (AVOPath *)path {
    if (!_path || !_sizeCalculator) {
        [self calculateDefaults];
    }
    return _path;
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
