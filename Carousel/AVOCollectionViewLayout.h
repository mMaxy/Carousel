//
//  AVOCollectionViewLayout.h
//  Carousel
//
//  Created by Artem Olkov on 21/06/15.
//  Copyright (c) 2015 aolkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AVOCollectionViewDelegateLayout <UICollectionViewDelegateFlowLayout>
@optional

- (void)collectionView:(UICollectionView *)collectionView tapOnCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView longpressOnCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView liftOnCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface AVOCollectionViewLayout : UICollectionViewLayout

@property (assign, nonatomic, readonly) id<AVOCollectionViewDelegateLayout> delegate;

@end
