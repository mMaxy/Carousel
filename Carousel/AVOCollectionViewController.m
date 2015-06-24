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

- (id)init {
    self = [super init];
    if (self) {
//        [self setDefaults];
//        [self addObserver:self forKeyPath:kLXCollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
//        [self setDefaults];
//        [self addObserver:self forKeyPath:kLXCollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
