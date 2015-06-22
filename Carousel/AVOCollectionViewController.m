//
//  AVOCollectionViewController.m
//  Carousel
//
//  Created by Artem Olkov on 20/06/15.
//  Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOCollectionViewController.h"
#import "AVOCollectionViewCell.h"

@interface AVOCollectionViewController ()

@property (assign, nonatomic, readonly) CGSize cellSize;
@property (assign, nonatomic, readonly) CGFloat verticalInset;
@property (assign, nonatomic, readonly) CGFloat horizontalInset;

@property (strong, nonatomic) CADisplayLink *displayLink;

@end

@implementation AVOCollectionViewController

static NSString * const reuseIdentifier = @"CarouselCell";

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayTimerTicked:)];

    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayTimerTicked:(CADisplayLink *)displayLink {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGSize) getCellSize {
    if (_cellSize.height == 0.f && _cellSize.width == 0.f) {
        CGFloat screenWidth = self.view.frame.size.width;
        CGFloat screenHeight = self.view.frame.size.height;
        CGFloat lineSpace = 5.f;
        CGFloat rowSpace = 5.f;
        CGFloat horizontalSpace = rowSpace * 4;
        CGFloat verticalSpace = lineSpace * 4;

        CGFloat possibleWidth;
        CGFloat possibleHeight;
        CGFloat totalHeight;
        CGFloat totalWidth;

        possibleWidth = (screenWidth - horizontalSpace) / 3;
        possibleHeight = possibleWidth * 4 / 3;
        totalHeight = possibleHeight * 3 + verticalSpace;
        totalWidth = possibleWidth * 3 + horizontalSpace;

        if (totalHeight > screenHeight || totalWidth > screenWidth) {

            possibleHeight = (screenHeight - verticalSpace) / 3;
            possibleWidth = possibleHeight * 3 / 4;
            totalHeight = possibleHeight * 3 + verticalSpace;
            totalWidth = possibleWidth * 3 + horizontalSpace;

            if (totalHeight > screenHeight || totalWidth > screenWidth) {
                return CGSizeZero;
            }

            _verticalInset = 5;
            _horizontalInset = (screenWidth + 2 * lineSpace - totalWidth) / 2 ;
            _cellSize = CGSizeMake(possibleWidth, possibleHeight);
        } else {
            _horizontalInset = 5;
            _verticalInset = (screenHeight + 2 * rowSpace - totalHeight) / 2;
            _cellSize = CGSizeMake(possibleWidth, possibleHeight);
        }
    }

    return _cellSize;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    AVOCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    if (indexPath.item == 4)
        [cell setBackgroundColor:[UIColor blueColor]];
    [cell.textLabel setText:[NSString stringWithFormat:@"%i", (indexPath.item + 1)]];

    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self getCellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(self.verticalInset, self.horizontalInset, self.verticalInset, self.horizontalInset);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
        minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
        minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.f;
}

#pragma mark <UICollectionViewDelegateFlowLayout> <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

@end
