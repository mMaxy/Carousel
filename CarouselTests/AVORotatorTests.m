//
//  AVORotatorTests.m
//  Carousel
//
//  Created by Artem Olkov on 25/06/15.
//  Copyright (c) 2015 aolkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AVOSizeCalculator.h"
#import "AVOPath.h"
#import "AVORotator.h"

@interface AVORotatorTests : XCTestCase

@property (strong, nonatomic) AVOPath *path;
@property (strong, nonatomic) AVOSizeCalculator *calc;
@property (strong, nonatomic) AVORotator *rotator;

@end

@implementation AVORotatorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // given
    self.path = [[AVOPath alloc] init];
    self.calc = [[AVOSizeCalculator alloc] init];
    self.rotator = [[AVORotator alloc] init];

    // when
    CGRect screen = CGRectMake(0.f, 0.f, 380.f, 500.f);
    [self.calc setRectToFit:screen];
    [self.path setSizeCalculator:self.calc];
}

-(void) testPoints {
    //given
    CGPoint p1;
    CGPoint p2;

    //when
    p1 = CGPointMake(5.f, 7.f);
    p2 = p1;

    p2.x = 300.f;

    XCTAssertEqual(p1.y, p2.y);
    XCTAssert(p1.x != p2.x);
}

@end
