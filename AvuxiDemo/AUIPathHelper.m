//
//  AUIPathHelper.m
//  DemoMap02
//
//  Created by Felix Lamouroux on 21.11.16.
//  Copyright © 2016 iosphere GmbH. All rights reserved.
//
// based on https://oleb.net/blog/2012/12/accessing-pretty-printing-cgpath-elements/

#import "AUIPathHelper.h"

@implementation UIBezierPath (OBAdditions)

- (void)ob_enumerateElementsUsingBlock:(OBUIBezierPathEnumerationHandler)handler {
    CGPathRef cgPath = self.CGPath;

    void CGPathEnumerationCallback(void *info, const CGPathElement *element);

    CGPathApply(cgPath, (__bridge void *_Nullable)(handler), CGPathEnumerationCallback);
}

@end

void CGPathEnumerationCallback(void *info, const CGPathElement *element) {
    OBUIBezierPathEnumerationHandler handler = (__bridge OBUIBezierPathEnumerationHandler)(info);

    if (handler) {
        handler(element);
    }
}
