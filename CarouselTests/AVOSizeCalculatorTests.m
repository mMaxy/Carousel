//
//  AVOSizeCalculatorTests.m
//  Carousel
//
//  Created by Artem Olkov on 22/06/15.
//  Copyright (c) 2015 aolkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AVOSizeCalculator.h"

@interface AVOSizeCalculatorTests : XCTestCase

@property (strong, nonatomic) AVOSizeCalculator * calc;

@end

@implementation AVOSizeCalculatorTests

- (void)setUp {
    [super setUp];

    self.calc = [[AVOSizeCalculator alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

-(void)testDefaultInitWithZero {
    // given

    // when

    // then
    XCTAssertEqual(self.calc.cellSize.width, CGSizeZero.width);
    XCTAssertEqual(self.calc.cellSize.height, CGSizeZero.height);

    XCTAssertEqual(self.calc.frameSize.width, CGSizeZero.width);
    XCTAssertEqual(self.calc.frameSize.height, CGSizeZero.height);

    XCTAssertEqual(self.calc.horizontalInset, 0.f);
    XCTAssertEqual(self.calc.verticalInset, 0.f);
}


- (void)test380x500 {
    // given
    CGRect screen = CGRectMake(0.f, 0.f, 380.f, 500.f);

    // when
    [self.calc setRectToFit:screen];

    // then
    XCTAssertEqual(self.calc.cellSize.width, 120.f);
    XCTAssertEqual(self.calc.cellSize.height, 160.f);

    XCTAssertEqual(self.calc.frameSize.width, 380.f);
    XCTAssertEqual(self.calc.frameSize.height, 500.f);

    XCTAssertEqual(self.calc.horizontalInset, 5.f);
    XCTAssertEqual(self.calc.verticalInset, 5.f);
}

- (void)testIP4ScreenPortrait {
    // given
    CGRect screen = CGRectMake(0.f, 0.f, 320.f, 480.f);

    // when
    [self.calc setRectToFit:screen];

    // then
    XCTAssertEqual(self.calc.cellSize.width, 100.f);
    XCTAssertEqual(self.calc.cellSize.height, 133.333333333f);

    XCTAssertEqual(self.calc.frameSize.width, 320.f);
    XCTAssertEqual(self.calc.frameSize.height, 420.f);

    XCTAssertEqual(self.calc.horizontalInset, 5.f);
    XCTAssertEqual(self.calc.verticalInset, 35.f);
}

- (void)testIP4ScreenLandscape {
    // given
    CGRect screen = CGRectMake(0.f, 0.f, 480.f, 320.f);

    // when
    [self.calc setRectToFit:screen];

    // then
    XCTAssertEqual(self.calc.cellSize.width, 75.f);
    XCTAssertEqual(self.calc.cellSize.height, 100.f);

    XCTAssertEqual(self.calc.frameSize.width, 245.f);
    XCTAssertEqual(self.calc.frameSize.height, 320.f);

    XCTAssertEqual(self.calc.horizontalInset, 122.5f);
    XCTAssertEqual(self.calc.verticalInset, 5.f);
}

@end
