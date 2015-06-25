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

@property (strong, nonatomic) AVORotator *rotator;
@property (assign, nonatomic) CGRect frame;

@end

@implementation AVORotatorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // given
    self.rotator = [[AVORotator alloc] init];

    // when
    self.frame = CGRectMake(0.f, 0.f, 300.f, 400.f);
}

-(void) testRotation_FromLeftTopCornerToRightTopCorner {
    //given
    CGPoint point = CGPointMake(0.f, 0.f);
    double angleBetweenCellsTop = atan(1.5/2);
    CGPoint res;

    //when
    res = [self.rotator rotatedPointFromPoint:point byAngle:-2 * angleBetweenCellsTop inFrame:self.frame];

    //then
    XCTAssertEqual(res.x, self.frame.size.width);
    XCTAssertEqual(res.y, 0.f);
}

-(void) testRotation_FromLeftTopCornerToTopSideCenter {
    //given
    CGPoint point = CGPointMake(0.f, 0.f);
    double angleBetweenCellsTop = atan(1.5/2);
    CGPoint res;

    //when
    res = [self.rotator rotatedPointFromPoint:point byAngle:-angleBetweenCellsTop inFrame:self.frame];

    //then
    XCTAssertEqual(res.x, self.frame.size.width / 2);
    XCTAssertEqual(res.y, 0.f);
}

-(void) testRotation_FromLeftTopCornerToLeftBotCorner {
    //given
    CGPoint point = CGPointMake(0.f, 0.f);
    double angleBetweenCellsTop = atan(1.5/2);
    double angleBetweenCellsBot = ((M_PI - 2*angleBetweenCellsTop) / 2);
    CGPoint res;

    //when
    res = [self.rotator rotatedPointFromPoint:point byAngle:2 * angleBetweenCellsBot inFrame:self.frame];

    //then
    XCTAssertEqual(res.x, 0.f);
    XCTAssertEqual(res.y, self.frame.size.height);
}

-(void) testRotation_FromLeftTopCornerToLeftSideCenter {
    //given
    CGPoint point = CGPointMake(0.f, 0.f);
    double angleBetweenCellsTop = atan(1.5/2);
    double angleBetweenCellsBot = (M_PI - 2*angleBetweenCellsTop) / 2;
    CGPoint res;

    //when
    res = [self.rotator rotatedPointFromPoint:point byAngle:angleBetweenCellsBot inFrame:self.frame];

    //then
    XCTAssertEqual(res.x, 0.f);
    XCTAssertEqual(res.y, self.frame.size.height / 2);
}





-(void) testPoints {
    //given
    CGPoint p1;
    CGPoint p2;

    //when
    p1 = CGPointMake(5.f, 7.f);
    p2 = p1;
    p2.x = 300.f;

    //then
    XCTAssertEqual(p1.y, p2.y);
    XCTAssert(p1.x != p2.x);
}

@end
