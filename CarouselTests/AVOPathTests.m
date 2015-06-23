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
    CGPoint point = [self.path getCenterForIndex:1];

    XCTAssertEqual(point.x, 65.f);
    XCTAssertEqual(point.y, 85.f);
}

- (void)testPlaceForTopCenter {
    CGPoint point = [self.path getCenterForIndex:2];

    XCTAssertEqual(point.x, 190.f);
    XCTAssertEqual(point.y, 85.f);
}

- (void)testPlaceForTopRight {
    CGPoint point = [self.path getCenterForIndex:3];

    XCTAssertEqual(point.x, 315.f);
    XCTAssertEqual(point.y, 85.f);
}

- (void)testPlaceForCenterLeft {
    CGPoint point = [self.path getCenterForIndex:8];

    XCTAssertEqual(point.x, 65.f);
    XCTAssertEqual(point.y, 250.f);
}

- (void)testPlaceForCenterRight {
    CGPoint point = [self.path getCenterForIndex:4];

    XCTAssertEqual(point.x, 315.f);
    XCTAssertEqual(point.y, 250.f);
}

- (void)testPlaceForBotLeft {
    CGPoint point = [self.path getCenterForIndex:7];

    XCTAssertEqual(point.x, 65.f);
    XCTAssertEqual(point.y, 415.f);
}

- (void)testPlaceForBotCenter {
    CGPoint point = [self.path getCenterForIndex:6];

    XCTAssertEqual(point.x, 190.f);
    XCTAssertEqual(point.y, 415.f);
}

- (void)testPlaceForBotRight {

    CGPoint point = [self.path getCenterForIndex:5];

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

#pragma mark Indexes In Rect

- (void)testIndexesInRect_full {
    //given
    CGRect rect = self.calc.rectToFit;
    NSArray *indexes;

    //when
    indexes = [self.path getIndexesInRect:rect];
    NSIndexPath *expected1 = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *expected2 = [NSIndexPath indexPathForItem:1 inSection:0];
    NSIndexPath *expected3 = [NSIndexPath indexPathForItem:2 inSection:0];
    NSIndexPath *expected4 = [NSIndexPath indexPathForItem:3 inSection:0];
    NSIndexPath *expected5 = [NSIndexPath indexPathForItem:4 inSection:0];
    NSIndexPath *expected6 = [NSIndexPath indexPathForItem:5 inSection:0];
    NSIndexPath *expected7 = [NSIndexPath indexPathForItem:6 inSection:0];
    NSIndexPath *expected8 = [NSIndexPath indexPathForItem:7 inSection:0];
    NSIndexPath *expected9 = [NSIndexPath indexPathForItem:8 inSection:0];

    // then
    XCTAssertTrue([indexes count] == 9);
    XCTAssertTrue([indexes containsObject:expected1]);
    XCTAssertTrue([indexes containsObject:expected2]);
    XCTAssertTrue([indexes containsObject:expected3]);
    XCTAssertTrue([indexes containsObject:expected4]);
    XCTAssertTrue([indexes containsObject:expected5]);
    XCTAssertTrue([indexes containsObject:expected6]);
    XCTAssertTrue([indexes containsObject:expected7]);
    XCTAssertTrue([indexes containsObject:expected8]);
    XCTAssertTrue([indexes containsObject:expected9]);

}

- (void)testIndexesInRect_cellCenter {
    //check for every cell
    NSMutableArray *indexes = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    for (NSIndexPath *ip in indexes) {
        //given
        CGPoint center = [self.path getCenterForIndex:(NSUInteger) ip.item];
        CGRect rect = CGRectMake(center.x - 10.f, center.y - 10.f, 20.f, 20.f);
        NSArray *res;

        //when
        res = [self.path getIndexesInRect:rect];
        NSIndexPath *expected1 = [NSIndexPath indexPathForItem:0 inSection:0];

        // then
        XCTAssertTrue([res count] == 1);
        XCTAssertTrue([res containsObject:expected1]);
    }
}

- (void)testIndexesInRect_emptyAroundCell_rows {
    //check for every cell
    NSMutableArray *pointsStart = [NSMutableArray new];
    for (int i = 0; i < self.calc.frameSize.height; i += self.calc.cellSize.height + self.calc.spaceBetweenCells) {
        for (int y = 0; y < self.calc.frameSize.width ; y += (self.calc.cellSize.width  - self.calc.spaceBetweenCells)/2) {
            [pointsStart addObject:[NSValue valueWithCGPoint:CGPointMake(i, y)]];
        }
    }

    for (NSValue *ip in pointsStart) {
        //given
        CGPoint start = [ip CGPointValue];
        CGRect rect = CGRectMake(start.x, start.y, self.calc.spaceBetweenCells, self.calc.spaceBetweenCells);
        NSArray *res;

        //when
        res = [self.path getIndexesInRect:rect];

        // then
        XCTAssertTrue([res count] == 0);
    }
}

- (void)testIndexesInRect_emptyAroundCell_columns {
    //check for every cell
    NSMutableArray *pointsStart = [NSMutableArray new];
    for (int i = 0; i < self.calc.frameSize.width;  i += self.calc.cellSize.width  + self.calc.spaceBetweenCells) {
        for (int y = 0; y < self.calc.frameSize.height; y += (self.calc.cellSize.height - self.calc.spaceBetweenCells)/2) {
            [pointsStart addObject:[NSValue valueWithCGPoint:CGPointMake(i, y)]];
        }
    }

    for (NSValue *ip in pointsStart) {
        //given
        CGPoint start = [ip CGPointValue];
        CGRect rect = CGRectMake(start.x, start.y, self.calc.spaceBetweenCells, self.calc.spaceBetweenCells);
        NSArray *res;

        //when
        res = [self.path getIndexesInRect:rect];

        // then
        XCTAssertTrue([res count] == 0);
    }
}

- (void)testIndexesInRect_cornersOuterLeftTop {
    //given
    CGRect rect = CGRectMake(0.f, 0.f, 60.f, 60.f);
    NSArray *indexes;

    //when
    indexes = [self.path getIndexesInRect:rect];
    NSIndexPath *expected1 = [NSIndexPath indexPathForItem:0 inSection:0];

    // then
    XCTAssertTrue([indexes count] == 1);
    XCTAssertTrue([indexes containsObject:expected1]);
}

- (void)testIndexesInRect_cornersOuterRightTop {
    //given
    CGRect rect = CGRectMake(320.f, 0.f, 60.f, 60.f);
    NSArray *indexes;

    //when
    indexes = [self.path getIndexesInRect:rect];
    NSIndexPath *expected1 = [NSIndexPath indexPathForItem:2 inSection:0];

    // then
    XCTAssertTrue([indexes count] == 1);
    XCTAssertTrue([indexes containsObject:expected1]);
}

- (void)testIndexesInRect_cornersOuterRightBot {
    //given
    CGRect rect = CGRectMake(320.f, 440.f, 60.f, 60.f);
    NSArray *indexes;

    //when
    indexes = [self.path getIndexesInRect:rect];
    NSIndexPath *expected1 = [NSIndexPath indexPathForItem:4 inSection:0];

    // then
    XCTAssertTrue([indexes count] == 1);
    XCTAssertTrue([indexes containsObject:expected1]);
}


- (void)testIndexesInRect_cornersOuterLeftBot {
    //given
    CGRect rect = CGRectMake(0.f, 440.f, 60.f, 60.f);
    NSArray *indexes;

    //when
    indexes = [self.path getIndexesInRect:rect];
    NSIndexPath *expected1 = [NSIndexPath indexPathForItem:6 inSection:0];

    // then
    XCTAssertTrue([indexes count] == 1);
    XCTAssertTrue([indexes containsObject:expected1]);
}

- (void)testIndexesInRect_cornersInsideLeftTop {
    //given
    CGRect rect = CGRectMake(100.f, 140.f, 60.f, 60.f);
    NSArray *indexes;

    //when
    indexes = [self.path getIndexesInRect:rect];
    NSIndexPath *expected1 = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *expected2 = [NSIndexPath indexPathForItem:1 inSection:0];
    NSIndexPath *expected3 = [NSIndexPath indexPathForItem:7 inSection:0];
    NSIndexPath *expected4 = [NSIndexPath indexPathForItem:8 inSection:0];

    // then
    XCTAssertTrue([indexes count] == 4);
    XCTAssertTrue([indexes containsObject:expected1]);
    XCTAssertTrue([indexes containsObject:expected2]);
    XCTAssertTrue([indexes containsObject:expected3]);
    XCTAssertTrue([indexes containsObject:expected4]);
}

- (void)testIndexesInRect_cornersInsideLeftBot {
    //given
    CGRect rect = CGRectMake(100.f, 390.f, 60.f, 60.f);
    NSArray *indexes;

    //when
    indexes = [self.path getIndexesInRect:rect];
    NSIndexPath *expected4 = [NSIndexPath indexPathForItem:5 inSection:0];
    NSIndexPath *expected1 = [NSIndexPath indexPathForItem:6 inSection:0];
    NSIndexPath *expected2 = [NSIndexPath indexPathForItem:7 inSection:0];
    NSIndexPath *expected3 = [NSIndexPath indexPathForItem:8 inSection:0];

    // then
    XCTAssertTrue([indexes count] == 4);
    XCTAssertTrue([indexes containsObject:expected1]);
    XCTAssertTrue([indexes containsObject:expected2]);
    XCTAssertTrue([indexes containsObject:expected3]);
    XCTAssertTrue([indexes containsObject:expected4]);
}

- (void)testIndexesInRect_cornersInsideRightTop {
    //given
    CGRect rect = CGRectMake(210.f, 140.f, 60.f, 60.f);
    NSArray *indexes;

    //when
    indexes = [self.path getIndexesInRect:rect];
    NSIndexPath *expected3 = [NSIndexPath indexPathForItem:1 inSection:0];
    NSIndexPath *expected1 = [NSIndexPath indexPathForItem:2 inSection:0];
    NSIndexPath *expected2 = [NSIndexPath indexPathForItem:3 inSection:0];
    NSIndexPath *expected4 = [NSIndexPath indexPathForItem:8 inSection:0];

    // then
    XCTAssertTrue([indexes count] == 4);
    XCTAssertTrue([indexes containsObject:expected1]);
    XCTAssertTrue([indexes containsObject:expected2]);
    XCTAssertTrue([indexes containsObject:expected3]);
    XCTAssertTrue([indexes containsObject:expected4]);
}

- (void)testIndexesInRect_cornersInsideRightBot {
    //given
    CGRect rect = CGRectMake(210.f, 390.f, 60.f, 60.f);
    NSArray *indexes;

    //when
    indexes = [self.path getIndexesInRect:rect];
    NSIndexPath *expected3 = [NSIndexPath indexPathForItem:3 inSection:0];
    NSIndexPath *expected1 = [NSIndexPath indexPathForItem:4 inSection:0];
    NSIndexPath *expected2 = [NSIndexPath indexPathForItem:5 inSection:0];
    NSIndexPath *expected4 = [NSIndexPath indexPathForItem:8 inSection:0];

    // then
    XCTAssertTrue([indexes count] == 4);
    XCTAssertTrue([indexes containsObject:expected1]);
    XCTAssertTrue([indexes containsObject:expected2]);
    XCTAssertTrue([indexes containsObject:expected3]);
    XCTAssertTrue([indexes containsObject:expected4]);
}

- (void)testIndexPaths {
    //given
    NSIndexPath *tmp1;
    NSIndexPath *tmp2;
    BOOL res;

    //when
    tmp1 = [NSIndexPath indexPathForItem:0 inSection:0];
    tmp2 = [NSIndexPath indexPathForItem:0 inSection:0];
    res = [tmp1 isEqual:tmp2];

    //then
    XCTAssertTrue(res);
    XCTAssertFalse(tmp1 == tmp2);
}

@end
