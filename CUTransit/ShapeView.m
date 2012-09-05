//
//  ShapeView.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "ShapeView.h"
#import "CUShape.h"

@implementation ShapeView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
	CUShape *shape = self.overlay;
	
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	
	BOOL first = YES;
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	for (NSData *point in shape.points) {
		CLLocationCoordinate2D coordinate;
		[point getBytes:&coordinate length:sizeof(CLLocationCoordinate2D)];
		MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
		CGPoint p = [self pointForMapPoint:mapPoint];
				
		if (first) {
			CGPathMoveToPoint(path, NULL, p.x, p.y);
			first = NO;
		} else {
			CGPathAddLineToPoint(path, NULL, p.x, p.y);
		}
	}
	
	CGFloat roadWidth = MKRoadWidthAtZoomScale(zoomScale);
	
	// draw border
	CGContextAddPath(context, path);
	CGContextSetLineWidth(context, 1.5 * roadWidth);
	if (!shape.highlighted)
		CGContextSetRGBStrokeColor(context, 0, 0.3, 1, 0.7);
	else
		CGContextSetRGBStrokeColor(context, 0, 0.3, 1, 0.9);
	CGContextStrokePath(context);
	
	// draw line
	CGContextAddPath(context, path);
	CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
	CGContextSetLineWidth(context, 1.2 * roadWidth);
	if (!shape.highlighted)
		CGContextSetRGBStrokeColor(context, 0, 0.3, 1, 0.3);
	else
		CGContextSetRGBStrokeColor(context, 0, 0.3, 1, 0.6);
	CGContextStrokePath(context);

	CGPathRelease(path);
}

@end
