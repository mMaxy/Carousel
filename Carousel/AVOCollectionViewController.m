//
//  AVOCollectionViewController.m
//  Carousel
//
//  Created by Artem Olkov on 20/06/15.
//  Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOCollectionViewController.h"
#import "AVOCollectionViewCell.h"
#import "AVOCollectionViewLayout.h"

@interface AVOCollectionViewController ()

@property (strong, nonatomic) CADisplayLink *displayLink;

@end

@implementation AVOCollectionViewController

static NSString * const reuseIdentifier = @"CarouselCell";


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    AVOCollectionViewLayout *layout = (AVOCollectionViewLayout *) self.collectionView.collectionViewLayout;
    [layout invalidateLayout];
    [self.collectionView performBatchUpdates:nil completion:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AVOCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    if (indexPath.item == 8)
        [cell setBackgroundColor:[UIColor blueColor]];
    [cell.textLabel setText:[NSString stringWithFormat:@"%i", (indexPath.item + 1)]];

    return cell;
}

@end
