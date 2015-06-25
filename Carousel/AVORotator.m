//
// Created by Artem Olkov on 25/06/15.
// Copyright (c) 2015 aolkov. All rights reserved.
//

#import "AVORotator.h"
#import "AVOSizeCalculator.h"

@interface AVORotator()


-(BOOL) increaseQuarterOfPoint:(CGPoint *)point inFrame:(CGRect *)frame;
-(BOOL) increaseQuarterOfAngle:(CGFloat *)angle inFrame:(CGRect *)frame;
-(BOOL) decreaseQuarterOfPoint:(CGPoint *)point inFrame:(CGRect *)frame;
-(BOOL) decreaseQuarterOfAngle:(CGFloat *)angle inFrame:(CGRect *)frame;

-(NSUInteger) defineQuarterForPoint:(CGPoint) point inFrame:(CGRect)frame;
-(NSUInteger) defineQuarterOfAngle:(CGFloat) angle inFrame:(CGRect)frame;

-(CGFloat) getAngleFromPoint:(CGPoint)point onFrame:(CGRect)frame;
-(CGPoint) getPointForAngle:(CGFloat)angle onFrame:(CGRect)frame;

@end

@implementation AVORotator {

}

- (CGPoint)rotateFromAngle:(CGFloat)from toAngle:(CGFloat)to inFrame:(CGRect)frame {
    CGPoint result;

    //TODO

    return result;
}

#pragma mark Private Methods

- (CGFloat)getAngleFromPoint:(CGPoint)point onFrame:(CGRect)frame {
    CGFloat res = 0.f;

    CGPoint p = point;
    CGRect f = frame;

    NSUInteger quarter = 0;

    while ([self decreaseQuarterOfPoint:&p inFrame:&f]) {
        quarter ++;
    }

    CGFloat x = p.x - f.size.width / 2;
    CGFloat y = f.size.height / 2 - p.y;

    double tg = tan(y/x);
    res = (CGFloat)atan(tg);

    while (quarter != 0) {
        [self decreaseQuarterOfAngle:&res inFrame:&f];
        quarter --;
    }

    return res;
}

- (CGPoint)getPointForAngle:(CGFloat)angle onFrame:(CGRect)frame {
    CGPoint res = CGPointZero;

    CGFloat a = angle;
    CGRect f = frame;

    NSUInteger quarter = 0;

    while ([self decreaseQuarterOfAngle:&a inFrame:&f]) {
        quarter ++;
    }

    CGFloat x;
    CGFloat y;
    CGFloat corner = [self getAngleFromPoint:CGPointMake(f.size.width, 0.f) onFrame:f];
    if (a > corner) {
        y = f.size.height / 2;
        x = y / (CGFloat) tan(a);
    } else {
        x = f.size.width / 2;
        y =  x *  (CGFloat) tan(a);
    }

    res = CGPointMake(f.size.width / 2 + x, y);

    while (quarter != 0) {
        [self decreaseQuarterOfPoint:&res inFrame:&f];
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

- (BOOL)increaseQuarterOfAngle:(CGFloat *)angle inFrame:(CGRect *)frame {
    if ([self defineQuarterOfAngle:(*angle) inFrame:(*frame)] == 3) {
        return NO;
    }
    *angle += M_PI_2;
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

- (BOOL)decreaseQuarterOfAngle:(CGFloat *)angle inFrame:(CGRect *)frame {
    if ([self defineQuarterOfAngle:(*angle) inFrame:(*frame)] == 0) {
        return NO;
    }
    *angle -= M_PI_2;
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

- (NSUInteger)defineQuarterOfAngle:(CGFloat)angle inFrame:(CGRect)frame {
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