//
//  AUIOverlay.m
//  AvuxiDemo
//
//  Created by Felix Lamouroux on 22.11.16.
//  Copyright © 2016 iosphere GmbH. All rights reserved.
//

#import "AUIOverlay.h"

static inline id ISHSafeCast(NSObject *obj, Class aClass) {
    return [obj isKindOfClass:aClass] ? obj : nil;
}

#define ISHSafeDict(var)   ISHSafeCast(var, [NSDictionary class])
#define ISHSafeArray(var)  ISHSafeCast(var, [NSArray class])
#define ISHSafeNumber(var) ISHSafeCast(var, [NSNumber class])
#define ISHSafeString(var) ISHSafeCast(var, [NSString class])

@interface AUIOverlayPolygon ()
@property (nonatomic, weak, readwrite) AUIOverlayLevel *level;
@property (nonatomic, readwrite) MKPolygon *polygon;
@property (nonatomic, nullable, copy, readwrite) NSString *title;
@end

@implementation AUIOverlayPolygon

+ (instancetype)polygonFromDictionary:(NSDictionary *)dict inLevel:(AUIOverlayLevel *)level {
    if (!dict) {
        return nil;
    }

    NSArray *jsonCoordinates = ISHSafeArray(dict[@"coords"]);

    if (!jsonCoordinates.count) {
        return nil;
    }

    NSUInteger count = 0;
    CLLocationCoordinate2D *coordinates = malloc(sizeof(CLLocationCoordinate2D) * jsonCoordinates.count);

    for (NSObject *jsonCoordinate in jsonCoordinates) {
        NSArray *array = ISHSafeArray(jsonCoordinate);

        if (array.count != 2) {
            continue;
        }

        NSNumber *lat = ISHSafeNumber(array[0]);
        NSNumber *lon = ISHSafeNumber(array[1]);

        if (!lat || !lon) {
            continue;
        }

        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
        coordinates[count] = coord;
        count++;
    }

    if (!count) {
        free(coordinates);
        return nil;
    }

    MKPolygon *mapPolygon = [MKPolygon polygonWithCoordinates:coordinates count:count];
    AUIOverlayPolygon *polygon = [self new];
    polygon.polygon = mapPolygon;
    polygon.title = ISHSafeString(dict[@"title"]);
    polygon.level = level;

    free(coordinates);

    return polygon;
}

- (CLLocationCoordinate2D)coordinate {
    return self.polygon.coordinate;
}

- (MKMapRect)boundingMapRect {
    return self.polygon.boundingMapRect;
}

@end

@interface AUIOverlayLevel ()
@property (nonatomic, readwrite) NSString *key;
@property (nonatomic, readwrite) CGFloat opacity;
@property (nonatomic, readwrite) NSArray<AUIOverlayPolygon *> *polygons;
@end

@implementation AUIOverlayLevel

+ (instancetype)levelFromDictionary:(NSDictionary *)dict {
    if (!dict) {
        return nil;
    }

    NSArray *jsonPolygons = ISHSafeArray(dict[@"polygons"]);

    if (!jsonPolygons.count) {
        return nil;
    }

    NSMutableArray *polygons = [NSMutableArray arrayWithCapacity:jsonPolygons.count];
    AUIOverlayLevel *level = [self new];

    for (NSObject *jsonPolygon in jsonPolygons) {
        AUIOverlayPolygon *polygon = [AUIOverlayPolygon polygonFromDictionary:ISHSafeDict(jsonPolygon) inLevel:level];

        if (!polygon) {
            continue;
        }

        [polygons addObject:polygon];
    }

    if (!polygons.count) {
        return nil;
    }

    level.polygons = polygons;
    level.key = ISHSafeString(dict[@"level"]);
    NSNumber *opacity = ISHSafeNumber(dict[@"opacity"]);
    level.opacity = opacity ? opacity.doubleValue : 0.1;

    return level;
}

@end

@interface AUIOverlay ()
@property (nonatomic, readwrite) NSArray<AUIOverlayLevel *> *levels;
@end

@implementation AUIOverlay

+ (instancetype)overlayFromData:(NSData *)data {
    NSError *jsonError;
    NSDictionary *jsonObj = ISHSafeDict([NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError]);

    if (!jsonObj || jsonError) {
        return nil;
    }

    // check for levels
    NSArray *jsonLevels = ISHSafeArray(jsonObj[@"levels"]);

    if (!jsonLevels.count) {
        return nil;
    }

    NSMutableArray *levels = [NSMutableArray arrayWithCapacity:jsonLevels.count];

    for (NSObject *jsonLevel in jsonLevels) {
        AUIOverlayLevel *level = [AUIOverlayLevel levelFromDictionary:ISHSafeDict(jsonLevel)];

        if (!level) {
            continue;
        }

        [levels addObject:level];
    }

    if (!levels.count) {
        return nil;
    }
    
    AUIOverlay *overlay = [self new];
    overlay.levels = levels;

    return overlay;
}

@end
