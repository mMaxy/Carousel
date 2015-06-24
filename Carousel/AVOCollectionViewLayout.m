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

@property (strong, nonatomic) AVOSizeCalculator *sizeCalculator;
@property (strong, nonatomic) AVOPath *path;

@end

@implementation AVOCollectionViewLayout

- (void)setCalcAndPath {
    self.sizeCalculator = [[AVOSizeCalculator alloc] init];
    self.path = [[AVOPath alloc] init];

    [self.sizeCalculator setRectToFit:self.collectionView.frame];
    [self.path setSizeCalculator:self.sizeCalculator];
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
    [self setPath:nil];
    [self setSizeCalculator:nil];
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
    frame.origin = CGPointMake(center.x - frame.size.width/2, center.y - frame.size.height/2);

    return frame;
}

- (AVOPath *)path {
    if (!_path || !_sizeCalculator) {
        [self setCalcAndPath];
    }
    return _path;
}

- (AVOSizeCalculator *)sizeCalculator {
    if (!_path || !_sizeCalculator) {
        [self setCalcAndPath];
    }
    return _sizeCalculator;
}


@end
