//
//  AvuxiDemoTests.m
//  AvuxiDemoTests
//
//  Created by Felix Lamouroux on 22.11.16.
//  Copyright © 2016 RA. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AUIOverlay.h"

@interface AUIOverlayTests : XCTestCase

@end

@implementation AUIOverlayTests

- (void)testExample {
    NSString *pathForTestFile = [[NSBundle bundleForClass:self.class] pathForResource:@"test" ofType:@"json"];
    XCTAssertNotNil(pathForTestFile);

    NSData *data = [NSData dataWithContentsOfFile:pathForTestFile];
    XCTAssertNotNil(data);

    AUIOverlay *overlay = [AUIOverlay overlayFromData:data];
    XCTAssertNotNil(overlay);
    XCTAssertNotNil(overlay.levels);
    XCTAssertEqual(overlay.levels.count, (NSUInteger)5);

    AUIOverlayLevel *level = overlay.levels.firstObject;
    XCTAssertEqual(level.polygons.count, (NSUInteger)7);
    XCTAssertEqual(level.opacity, (CGFloat)0.3);
    XCTAssertEqualObjects(level.key, @"E");

    AUIOverlayPolygon *polygon = level.polygons.firstObject;
    XCTAssertNotNil(polygon.polygon);
    XCTAssertEqualObjects(polygon.title, @"Test Title");
    XCTAssertEqualObjects(polygon.title, @"Test Title");
}

@end
