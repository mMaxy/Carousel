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
    CGPoint point = [self.path getCenterForIndex:0];

    XCTAssertEqual(point.x, 65.f);
    XCTAssertEqual(point.y, 85.f);
}

- (void)testPlaceForTopCenter {
    CGPoint point = [self.path getCenterForIndex:1];

    XCTAssertEqual(point.x, 190.f);
    XCTAssertEqual(point.y, 85.f);
}

- (void)testPlaceForTopRight {
    CGPoint point = [self.path getCenterForIndex:2];

    XCTAssertEqual(point.x, 315.f);
    XCTAssertEqual(point.y, 85.f);
}

- (void)testPlaceForCenterLeft {
    CGPoint point = [self.path getCenterForIndex:7];

    XCTAssertEqual(point.x, 65.f);
    XCTAssertEqual(point.y, 250.f);
}

- (void)testPlaceForCenterCenter {
    CGPoint point = [self.path getCenterForIndex:8];

    XCTAssertEqual(point.x, 190.f);
    XCTAssertEqual(point.y, 250.f);
}

- (void)testPlaceForCenterRight {
    CGPoint point = [self.path getCenterForIndex:3];

    XCTAssertEqual(point.x, 315.f);
    XCTAssertEqual(point.y, 250.f);
}

- (void)testPlaceForBotLeft {
    CGPoint point = [self.path getCenterForIndex:6];

    XCTAssertEqual(point.x, 65.f);
    XCTAssertEqual(point.y, 415.f);
}

- (void)testPlaceForBotCenter {
    CGPoint point = [self.path getCenterForIndex:5];

    XCTAssertEqual(point.x, 190.f);
    XCTAssertEqual(point.y, 415.f);
}

- (void)testPlaceForBotRight {

    CGPoint point = [self.path getCenterForIndex:4];

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
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        CGPoint pointTopLeft  = CGPointMake(center.x - size.width / 2, center.y - size.height / 2);

        //when
        NSIndexPath *resTopLeft = [self.path getCellIndexWithPoint:pointTopLeft];

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
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        CGPoint pointTopRight = CGPointMake(center.x + size.width / 2, center.y - size.height / 2);

        //when
        NSIndexPath *resTopRight = [self.path getCellIndexWithPoint:pointTopRight];

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
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        CGPoint pointBotLeft  = CGPointMake(center.x - size.width / 2, center.y + size.height / 2);

        //when
        NSIndexPath *resBotLeft = [self.path getCellIndexWithPoint:pointBotLeft];

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
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        CGPoint pointBotRight = CGPointMake(center.x + size.width / 2, center.y + size.height / 2);

        //when
        NSIndexPath *resBotRight = [self.path getCellIndexWithPoint:pointBotRight];

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
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];

        //when
        NSIndexPath *resCenter = [self.path getCellIndexWithPoint:center];

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
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        CGPoint pointTopLeft  = CGPointMake(center.x - size.width / 2 - 1.f, center.y - size.height / 2 - 1.f);
        CGPoint pointTopRight = CGPointMake(center.x + size.width / 2 + 1.f, center.y - size.height / 2 - 1.f);
        CGPoint pointBotLeft  = CGPointMake(center.x - size.width / 2 - 1.f, center.y + size.height / 2 + 1.f);
        CGPoint pointBotRight = CGPointMake(center.x + size.width / 2 + 1.f, center.y + size.height / 2 + 1.f);

        //when
        NSIndexPath *resTopLeft  = [self.path getCellIndexWithPoint:pointTopLeft];
        NSIndexPath *resTopRight = [self.path getCellIndexWithPoint:pointTopRight];
        NSIndexPath *resBotLeft  = [self.path getCellIndexWithPoint:pointBotLeft];
        NSIndexPath *resBotRight = [self.path getCellIndexWithPoint:pointBotRight];

        //then
        XCTAssertTrue(resTopLeft  == nil);
        XCTAssertTrue(resTopRight == nil);
        XCTAssertTrue(resBotLeft  == nil);
        XCTAssertTrue(resBotRight == nil);

    }
}

#pragma mark Nearest Cell Index

- (void)testNearestCellIndex_outsideCell_left {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        NSIndexPath *resLeft;
        CGPoint resDirectionFromLeft;
        CGFloat resDistanceLeft;

        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;

        //when
        CGPoint pointLeft  = CGPointMake(center.x - size.width / 2 - 2.f, center.y);
        resLeft = [self.path getNearestCellIndexFromPoint:pointLeft withResultDirection:&resDirectionFromLeft andResultDistance:&resDistanceLeft];

        // then
        XCTAssertTrue([resLeft isEqual:ip]);
        XCTAssertEqual(resDirectionFromLeft.x, 1.f);
        XCTAssertEqual(resDirectionFromLeft.y, 0.f);
        XCTAssertEqual(resDistanceLeft, size.width / 2.f + 2.f);
    }
}

- (void)testNearestCellIndex_outsideCell_right {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        NSIndexPath *resRight;
        CGPoint resDirectionFromRight;
        CGFloat resDistanceRight;

        //when
        CGPoint pointRight = CGPointMake(center.x + size.width / 2 + 2.f, center.y);
        resRight = [self.path getNearestCellIndexFromPoint:pointRight withResultDirection:&resDirectionFromRight andResultDistance:&resDistanceRight];

        // then
        XCTAssertTrue([resRight isEqual:ip]);
        XCTAssertEqual(resDirectionFromRight.x, -1.f);
        XCTAssertEqual(resDirectionFromRight.y, 0.f);
        XCTAssertEqual(resDistanceRight, size.width / 2.f + 2.f);
    }
}

- (void)testNearestCellIndex_outsideCell_top {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        NSIndexPath *resTop;
        CGPoint resDirectionFromTop;
        CGFloat resDistanceTop;

        //when
        CGPoint pointTop   = CGPointMake(center.x, center.y - size.height / 2 - 2.f);
        resTop = [self.path getNearestCellIndexFromPoint:pointTop withResultDirection:&resDirectionFromTop andResultDistance:&resDistanceTop];

        // then
        XCTAssertTrue([resTop isEqual:ip]);
        XCTAssertEqual(resDirectionFromTop.x, 0.f);
        XCTAssertEqual(resDirectionFromTop.y, 1.f);
        XCTAssertEqual(resDistanceTop, size.height / 2.f + 2.f);
    }
}

- (void)testNearestCellIndex_outsideCell_bot {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        CGSize size = self.calc.cellSize;
        NSIndexPath *resBot;
        CGPoint resDirectionFromBot;
        CGFloat resDistanceBot;

        //when
        CGPoint pointBot   = CGPointMake(center.x, center.y + size.height / 2 + 2.f);

        resBot = [self.path getNearestCellIndexFromPoint:pointBot withResultDirection:&resDirectionFromBot andResultDistance:&resDistanceBot];

        // then
        XCTAssertTrue([resBot isEqual:ip]);
        XCTAssertEqual(resDirectionFromBot.x, 0.f);
        XCTAssertEqual(resDirectionFromBot.y, -1.f);
        XCTAssertEqual(resDistanceBot, size.height / 2.f + 2.f);
    }
}

- (void)testNearestCellIndex_insideCell_left {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        NSIndexPath *resLeft;
        CGPoint resDirectionFromLeft;
        CGFloat resDistanceLeft;
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];

        //when
        CGPoint pointLeft  = CGPointMake(center.x - 2.f, center.y);
        resLeft = [self.path getNearestCellIndexFromPoint:pointLeft withResultDirection:&resDirectionFromLeft andResultDistance:&resDistanceLeft];

        // then
        XCTAssertTrue([resLeft isEqual:ip]);
        XCTAssertEqual(resDirectionFromLeft.x, 1.f);
        XCTAssertEqual(resDirectionFromLeft.y, 0.f);
        XCTAssertEqual(resDistanceLeft, 2.f);
    }
}

- (void)testNearestCellIndex_insideCell_right {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        NSIndexPath *resRight;
        CGPoint resDirectionFromRight;
        CGFloat resDistanceRight;

        //when
        CGPoint pointRight = CGPointMake(center.x + 2.f, center.y);
        resRight = [self.path getNearestCellIndexFromPoint:pointRight withResultDirection:&resDirectionFromRight andResultDistance:&resDistanceRight];

        // then
        XCTAssertTrue([resRight isEqual:ip]);
        XCTAssertEqual(resDirectionFromRight.x, -1.f);
        XCTAssertEqual(resDirectionFromRight.y, 0.f);
        XCTAssertEqual(resDistanceRight, 2.f);
    }
}

- (void)testNearestCellIndex_insideCell_top {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        NSIndexPath *resTop;
        CGPoint resDirectionFromTop;
        CGFloat resDistanceTop;

        //when
        CGPoint pointTop   = CGPointMake(center.x, center.y - 2.f);
        resTop = [self.path getNearestCellIndexFromPoint:pointTop withResultDirection:&resDirectionFromTop andResultDistance:&resDistanceTop];

        // then
        XCTAssertTrue([resTop isEqual:ip]);
        XCTAssertEqual(resDirectionFromTop.x, 0.f);
        XCTAssertEqual(resDirectionFromTop.y, 1.f);
        XCTAssertEqual(resDistanceTop, 2.f);
    }
}

- (void)testNearestCellIndex_insideCell_bot {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        NSIndexPath *resBot;
        CGPoint resDirectionFromBot;
        CGFloat resDistanceBot;

        //when
        CGPoint pointBot   = CGPointMake(center.x, center.y + 2.f);

        resBot = [self.path getNearestCellIndexFromPoint:pointBot withResultDirection:&resDirectionFromBot andResultDistance:&resDistanceBot];

        // then
        XCTAssertTrue([resBot isEqual:ip]);
        XCTAssertEqual(resDirectionFromBot.x, 0.f);
        XCTAssertEqual(resDirectionFromBot.y, -1.f);
        XCTAssertEqual(resDistanceBot, 2.f);
    }
}

@end
