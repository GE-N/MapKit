//
//  MRMercatorProjection.m
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRMercatorProjection.h"

@implementation MRMercatorProjection

- (CGPoint)pointForCoordinate:(MRMapCoordinate)coordinate
                    zoomLevel:(float)zoom tileSize:(CGSize)tileSize {

    NSUInteger _zoom = zoom;

    double sinLatitude = sin(coordinate.latitude * M_PI / 180);
    double scale = 1 + (zoom - _zoom);

    CGSize scaledTileSize = CGSizeMake(
                                  ((long) tileSize.width << _zoom) * scale,
                                  ((long) tileSize.height << _zoom) * scale
                                  );

    CGFloat x = ((coordinate.longitude + 180) / 360) * scaledTileSize.width;
    CGFloat y = (0.5 - log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * M_PI)) * scaledTileSize.height;

    return CGPointMake(x, y);
}

- (MRMapCoordinate)coordinateForPoint:(CGPoint)point zoomLevel:(NSUInteger)zoom 
							 tileSize:(CGSize)tileSize {
	
	MRLongitude lon = 360 * ((point.x / ((long) tileSize.width << zoom)) - 0.5);
	
	double y = 0.5 - (point.y / ((long) tileSize.height << zoom));
	MRLatitude lat = 90 - 360 * atan(exp(-y * 2 * M_PI)) / M_PI;
	
	return MRMapCoordinateMake(lat, lon);
}

@end
