//
//  MRMercatorProjection.m
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRMercatorProjection.h"

@implementation MRMercatorProjection

- (CGPoint)pointForCoordinate:(MRMapCoordinate)coordinate
					zoomLevel:(NSUInteger)zoom tileSize:(CGSize)tileSize {
	
	double sinLatitude = sin(coordinate.latitude * M_PI / 180);
	CGFloat y = ((0.5 - log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * M_PI)) * ((long) tileSize.height << zoom));
	CGFloat x = ((coordinate.longitude + 180) / 360 * ((long) tileSize.width << zoom));
	
	return CGPointMake(x, y);
}

- (CGPoint)scaledPointForCoordinate:(MRMapCoordinate)coordinate zoomScale:(float)zoomScale contentSize:(CGSize)contentSize tileSize:(CGSize)tileSize andOffset:(CGPoint)offset
{
    // Basically MRMapZoomLevelFromScale(self.zoomScale), except not throwing away the decimal.
    float zoomLevel = log2(zoomScale);

    // Calculate how many tiles there should be based on zoomLevel, which will be correct no matter what zoom level we're actually at
    NSUInteger numTiles = 1 << (long)floor(zoomLevel);

    // Calculate scaled tileSize, we'll use this as our scaling factor below.
    // I'm keeping these separate just in case we have different tile width/height in the future
    float horizScale = (contentSize.width / numTiles) / tileSize.width;
    float vertScale = (contentSize.height / numTiles) / tileSize.height;

    // Calculate the unscaled point
    CGPoint pt = [self pointForCoordinate:coordinate
                                          zoomLevel:zoomLevel
                                           tileSize:tileSize];
    // Scale the point
    pt.x *= horizScale;
    pt.y *= vertScale;

    pt.x += offset.x;
    pt.y += offset.y;

    return pt;
}

- (MRMapCoordinate)coordinateForPoint:(CGPoint)point zoomLevel:(NSUInteger)zoom
							 tileSize:(CGSize)tileSize {
	
	MRLongitude lon = 360 * ((point.x / ((long) tileSize.width << zoom)) - 0.5);
	
	double y = 0.5 - (point.y / ((long) tileSize.height << zoom));
	MRLatitude lat = 90 - 360 * atan(exp(-y * 2 * M_PI)) / M_PI;
	
	return MRMapCoordinateMake(lat, lon);
}

-(MRMapCoordinate)coordinateForPoint:(CGPoint)point zoomScale:(float)zoomScale contentSize:(CGSize)contentSize tileSize:(CGSize)tileSize andOffset:(CGPoint)offset
{
    point.x -= offset.x;
    point.y -= offset.y;

    // Basically MRMapZoomLevelFromScale(self.zoomScale), except not throwing away the decimal.
    float zoomLevel = log2(zoomScale);

    // Calculate how many tiles there should be based on zoomLevel, which will be correct no matter what zoom level we're actually at
    NSUInteger numTiles = 1 << (long)floor(zoomLevel);

    // Calculate scaled tileSize, we'll use this as our scaling factor below.
    // I'm keeping these separate just in case we have different tile width/height in the future
    float horizScale = (contentSize.width / numTiles) / tileSize.width;
    float vertScale = (contentSize.height / numTiles) / tileSize.height;

    CGFloat width = ((long) tileSize.width << (long)zoomLevel) * horizScale;
    CGFloat height = ((long) tileSize.height << (long)zoomLevel) * vertScale;
	MRLongitude lon = 360 * ((point.x / width) - 0.5);

	double y = 0.5 - (point.y / height);
	MRLatitude lat = 90 - 360 * atan(exp(-y * 2 * M_PI)) / M_PI;

	return MRMapCoordinateMake(lat, lon);
}

@end
