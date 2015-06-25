//
// Created by Artem Olkov on 25/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVORotator.h"
#import "AVOSizeCalculator.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@interface AVORotator()


-(BOOL) increaseQuarterOfPoint:(CGPoint *)point inFrame:(CGRect *)frame;
-(BOOL) increaseQuarterOfAngle:(double *)angle inFrame:(CGRect *)frame;
-(BOOL) decreaseQuarterOfPoint:(CGPoint *)point inFrame:(CGRect *)frame;
-(BOOL) decreaseQuarterOfAngle:(double *)angle inFrame:(CGRect *)frame;

-(NSUInteger) defineQuarterForPoint:(CGPoint) point inFrame:(CGRect)frame;
-(NSUInteger) defineQuarterOfAngle:(double) angle inFrame:(CGRect)frame;

-(double) getAngleFromPoint:(CGPoint)point onFrame:(CGRect)frame;
-(CGPoint) getPointForAngle:(double)angle onFrame:(CGRect)frame;

@end

@implementation AVORotator {

}

- (CGPoint)rotatedPointFromPoint:(CGPoint)from byAngle:(double)angle inFrame:(CGRect)frame {
    CGPoint result;

    double startAngle = [self getAngleFromPoint:from onFrame:frame];

    startAngle += angle;
    while (startAngle < 0.f) {
        startAngle += 2 * M_PI;
    }
    while (startAngle >= 2 * M_PI) {
        startAngle -= 2 * M_PI;
    }

    result = [self getPointForAngle:startAngle onFrame:frame];

    return result;
}

#pragma mark Private Methods

- (double)getAngleFromPoint:(CGPoint)point onFrame:(CGRect)frame {
    double res;

    CGPoint p = point;
    CGRect f = frame;

    NSUInteger quarter = 0;

    while ([self decreaseQuarterOfPoint:&p inFrame:&f]) {
        quarter ++;
    }

    CGFloat x = p.x - f.size.width / 2;
    CGFloat y = f.size.height / 2 - p.y;

    double tg = y/x;
    res = atan(tg);

    while (quarter != 0) {
        [self increaseQuarterOfAngle:&res inFrame:&f];
        quarter --;
    }

    return res;
}

- (CGPoint)getPointForAngle:(double)angle onFrame:(CGRect)frame {
    CGPoint res;

    double a = angle;
    CGRect f = frame;
    NSUInteger quarter = 0;

    while ([self decreaseQuarterOfAngle:&a inFrame:&f]) {
        quarter ++;
    }

    double x;
    double y;
    double corner = [self getAngleFromPoint:CGPointMake(f.size.width, 0.f) onFrame:f];
    if (a > corner) {
        y = f.size.height / 2;
        x = y / tan(a);
    } else {
        x = f.size.width / 2;
        y =  x * tan(a);
    }

    res = CGPointMake((CGFloat) (f.size.width / 2 + x), (CGFloat) (f.size.height / 2 - y));

    while (quarter != 0) {
        [self increaseQuarterOfPoint:&res inFrame:&f];
        quarter --;
    }

    return res;
}

#pragma mark Private Helpers

- (BOOL)increaseQuarterOfPoint:(CGPoint *)point inFrame:(CGRect *)frame {
    NSUInteger quarter = [self defineQuarterForPoint:*point inFrame:*frame];
    if (quarter == 3) {
        return NO;
    } else {
        *point = CGPointMake((*point).y, (*frame).size.width - (*point).x);
        *frame = CGRectMake(0.f, 0.f, (*frame).size.height, (*frame).size.width);
    }
    return YES;
}

- (BOOL)increaseQuarterOfAngle:(double *)angle inFrame:(CGRect *)frame {
    if ([self defineQuarterOfAngle:(*angle) inFrame:(*frame)] == 3) {
        return NO;
    }
    *angle += M_PI_2;
    *frame = CGRectMake(0.f, 0.f, (*frame).size.height, (*frame).size.width);
    return YES;
}

- (BOOL)decreaseQuarterOfPoint:(CGPoint *)point inFrame:(CGRect *)frame {
    NSUInteger quarter = [self defineQuarterForPoint:*point inFrame:*frame];
    if (quarter == 0) {
        return NO;
    } else {
        *point = CGPointMake((*frame).size.height - (*point).y, (*point).x);
        *frame = CGRectMake(0.f, 0.f, (*frame).size.height, (*frame).size.width);
    }
    return YES;
}

- (BOOL)decreaseQuarterOfAngle:(double *)angle inFrame:(CGRect *)frame {
    if ([self defineQuarterOfAngle:(*angle) inFrame:(*frame)] == 0) {
        return NO;
    }
    *angle -= M_PI_2;
    *frame = CGRectMake(0.f, 0.f, (*frame).size.height, (*frame).size.width);
    return YES;
}

- (NSUInteger)defineQuarterForPoint:(CGPoint)point inFrame:(CGRect)frame {
    CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
    if (point.x > center.x) {
        if (point.y <= center.y) {
            return 0;
        } else {
            return 3;
        }
    } else {
        if (point.y < center.y) {
            return 1;
        } else {
            return 2;
        }
    }
}

- (NSUInteger)defineQuarterOfAngle:(double)angle inFrame:(CGRect)frame {
    if (angle >= 0.f && angle < M_PI_2) {
        return 0;
    } else if (angle >= M_PI_2 && angle < M_PI) {
        return 1;
    } else if (angle >= M_PI && angle < M_PI + M_PI_2) {
        return 2;
    } else  if (angle >= M_PI + M_PI_2 && angle < 2 * M_PI) {
        return 3;
    } else {
        return NAN;
    }
}

@end