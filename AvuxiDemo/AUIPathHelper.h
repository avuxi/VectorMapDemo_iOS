//
//  AUIPathHelper.h
//  DemoMap02
//
//  Created by Felix Lamouroux on 21.11.16.
//  Copyright © 2016 iosphere GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OBUIBezierPathEnumerationHandler)(const CGPathElement *element);

@interface UIBezierPath (OBAdditions)

- (void)ob_enumerateElementsUsingBlock:(OBUIBezierPathEnumerationHandler)handler;

@end
