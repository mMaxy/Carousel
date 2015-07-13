//
//  AVOCarouselViewController.m
//  Carousel
//
//  Created by Artem Olkov on 11/07/15.
//  Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVOCarouselViewController.h"
#import "AVOCarouselView.h"

@interface AVOCarouselViewController () <AVOCarouselViewDelegate>

@property(weak, nonatomic) IBOutlet AVOCarouselView *carousel;

@end

@implementation AVOCarouselViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.carousel setDelegate:self];

}

- (void)viewDidLayoutSubviews {
    [self.carousel setFrame:self.view.bounds];
    NSMutableArray *cells = [NSMutableArray new];
    for (int index = 0; index < 9; index++) {
        UILabel *cell = [UILabel new];
        [cell setBackgroundColor:[UIColor redColor]];
        [cell setTextAlignment:NSTextAlignmentCenter];
        if (index == 8)
            [cell setBackgroundColor:[UIColor blueColor]];
        [cell setText:[NSString stringWithFormat:@"%i", index + 1]];
        [cells addObject:cell];
    }
    [self.carousel setCells:cells];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <AVOCollectionViewDelegateLayout>

- (void)carouselView:(AVOCarouselView *)carouselView tapOnCellAtIndex:(NSUInteger)index {
    NSLog(@"Tap #%i", index + 1);
}

- (void)carouselView:(AVOCarouselView *)carouselView longpressOnCellAtIndex:(NSUInteger)index {
    NSLog(@"Longpress start #%i", index + 1);
}

- (void)carouselView:(AVOCarouselView *)carouselView liftOnCellAtIndex:(NSUInteger)index {
    NSLog(@"End Longpress #%i", index + 1);
}

@end
