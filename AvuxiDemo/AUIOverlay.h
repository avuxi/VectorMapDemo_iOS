//
//  AUIOverlay.h
//  AvuxiDemo
//
//  Created by Felix Lamouroux on 22.11.16.
//  Copyright © 2016 RA. All rights reserved.
//

#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AUIOverlayLevel;

@interface AUIOverlayPolygon : NSObject <MKOverlay>
@property (nonatomic, weak, readonly) AUIOverlayLevel *level;
@property (nonatomic, readonly) MKPolygon *polygon;
@property (nonatomic, nullable, copy, readonly) NSString *title;
@end

@interface AUIOverlayLevel : NSObject
@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) CGFloat opacity;
@property (nonatomic, readonly) NSArray<AUIOverlayPolygon *> *polygons;
@end

@interface AUIOverlay : NSObject
+ (nullable instancetype)overlayFromData:(NSData *)data;
@property (nonatomic, readonly) NSArray<AUIOverlayLevel *> *levels;
@end

NS_ASSUME_NONNULL_END
