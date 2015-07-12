//
//  AVOPathTests.m
//  Carousel
//
//  Created by Artem Olkov on 22/06/15.
//  Copyright (c) 2015 aolkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AVOPath.h"
#import "AVOSizeCalculator.h"

@interface AVOPathTests : XCTestCase

@property (strong, nonatomic) AVOPath *path;
@property (strong, nonatomic) AVOSizeCalculator *calc;

@end

@implementation AVOPathTests

- (void)setUp {
    [super setUp];

    // given
    self.path = [[AVOPath alloc] init];
    self.calc = [[AVOSizeCalculator alloc] init];

    // when
    CGRect screen = CGRectMake(0.f, 0.f, 380.f, 500.f);
    [self.calc setRectToFit:screen];
    [self.path setSizeCalculator:self.calc];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark Center For Index

- (void)testPlaceForTopLeft {
    CGPoint point = [self.path calculateCenterForIndex:0];

    XCTAssertEqual(point.x, 65.f);
    XCTAssertEqual(point.y, 85.f);
}

- (void)testPlaceForTopCenter {
    CGPoint point = [self.path calculateCenterForIndex:1];

    XCTAssertEqual(point.x, 190.f);
    XCTAssertEqual(point.y, 85.f);
}

- (void)testPlaceForTopRight {
    CGPoint point = [self.path calculateCenterForIndex:2];

    XCTAssertEqual(point.x, 315.f);
    XCTAssertEqual(point.y, 85.f);
}

- (void)testPlaceForCenterLeft {
    CGPoint point = [self.path calculateCenterForIndex:7];

    XCTAssertEqual(point.x, 65.f);
    XCTAssertEqual(point.y, 250.f);
}

- (void)testPlaceForCenterCenter {
    CGPoint point = [self.path calculateCenterForIndex:8];

    XCTAssertEqual(point.x, 190.f);
    XCTAssertEqual(point.y, 250.f);
}

- (void)testPlaceForCenterRight {
    CGPoint point = [self.path calculateCenterForIndex:3];

    XCTAssertEqual(point.x, 315.f);
    XCTAssertEqual(point.y, 250.f);
}

- (void)testPlaceForBotLeft {
    CGPoint point = [self.path calculateCenterForIndex:6];

    XCTAssertEqual(point.x, 65.f);
    XCTAssertEqual(point.y, 415.f);
}

- (void)testPlaceForBotCenter {
    CGPoint point = [self.path calculateCenterForIndex:5];

    XCTAssertEqual(point.x, 190.f);
    XCTAssertEqual(point.y, 415.f);
}

- (void)testPlaceForBotRight {

    CGPoint point = [self.path calculateCenterForIndex:4];

    XCTAssertEqual(point.x, 315.f);
    XCTAssertEqual(point.y, 415.f);
}

#pragma mark Cell For Point

- (void)testCellForPoint_topLeft {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path calculateCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        CGPoint pointTopLeft  = CGPointMake(center.x - size.width / 2, center.y - size.height / 2);

        //when
        NSIndexPath *resTopLeft = [self.path findCellIndexWithPoint:pointTopLeft];

        //then
        XCTAssertTrue([resTopLeft isEqual:ip]);
    }
}

- (void)testCellForPoint_topRight {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path calculateCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        CGPoint pointTopRight = CGPointMake(center.x + size.width / 2, center.y - size.height / 2);

        //when
        NSIndexPath *resTopRight = [self.path findCellIndexWithPoint:pointTopRight];

        //then
        XCTAssertTrue([resTopRight isEqual:ip]);
    }
}

- (void)testCellForPoint_botLeft {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path calculateCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        CGPoint pointBotLeft  = CGPointMake(center.x - size.width / 2, center.y + size.height / 2);

        //when
        NSIndexPath *resBotLeft = [self.path findCellIndexWithPoint:pointBotLeft];

        //then
        XCTAssertTrue([resBotLeft isEqual:ip]);
    }
}

- (void)testCellForPoint_botRight {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path calculateCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        CGPoint pointBotRight = CGPointMake(center.x + size.width / 2, center.y + size.height / 2);

        //when
        NSIndexPath *resBotRight = [self.path findCellIndexWithPoint:pointBotRight];

        //then
        XCTAssertTrue([resBotRight isEqual:ip]);
    }
}

- (void)testCellForPoint_center {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path calculateCenterForIndex:(NSUInteger) ip.item];

        //when
        NSIndexPath *resCenter = [self.path findCellIndexWithPoint:center];

        //then
        XCTAssertTrue([resCenter isEqual:ip]);
    }
}

- (void)testCellForPoint_empty {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path calculateCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        CGPoint pointTopLeft  = CGPointMake(center.x - size.width / 2 - 1.f, center.y - size.height / 2 - 1.f);
        CGPoint pointTopRight = CGPointMake(center.x + size.width / 2 + 1.f, center.y - size.height / 2 - 1.f);
        CGPoint pointBotLeft  = CGPointMake(center.x - size.width / 2 - 1.f, center.y + size.height / 2 + 1.f);
        CGPoint pointBotRight = CGPointMake(center.x + size.width / 2 + 1.f, center.y + size.height / 2 + 1.f);

        //when
        NSIndexPath *resTopLeft  = [self.path findCellIndexWithPoint:pointTopLeft];
        NSIndexPath *resTopRight = [self.path findCellIndexWithPoint:pointTopRight];
        NSIndexPath *resBotLeft  = [self.path findCellIndexWithPoint:pointBotLeft];
        NSIndexPath *resBotRight = [self.path findCellIndexWithPoint:pointBotRight];

        //then
        XCTAssertTrue(resTopLeft  == nil);
        XCTAssertTrue(resTopRight == nil);
        XCTAssertTrue(resBotLeft  == nil);
        XCTAssertTrue(resBotRight == nil);

    }
}

@end
