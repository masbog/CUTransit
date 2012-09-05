//
//  CUShape.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CUShape.h"

@implementation CUShape

@synthesize points, boundingMapRect, highlighted, hidden;

- (id)initWithObject:(id)obj {
	if (self = [super init]) {
		NSMutableArray *mutablePoints = [NSMutableArray array];
		
		double minLat = DBL_MAX, minLon = DBL_MAX;
		double maxLat = -DBL_MAX, maxLon = -DBL_MAX;
		
		for (NSDictionary *point in obj) {
			double lat = [[point objectForKey:@"shape_pt_lat"] doubleValue];
			double lon = [[point objectForKey:@"shape_pt_lon"] doubleValue];
			minLat = MIN(lat, minLat);
			minLon = MIN(lon, minLon);
			maxLat = MAX(lat, maxLat);
			maxLon = MAX(lon, maxLon);
			
			CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lat, lon);
			NSData *data = [[NSData alloc] initWithBytes:&coor length:sizeof(CLLocationCoordinate2D)];
			[mutablePoints addObject:data];
			[data release];
		}
		
		self.points = mutablePoints;
		
		CLLocationCoordinate2D origin = CLLocationCoordinate2DMake(maxLat, minLon);
		MKMapPoint upperLeft = MKMapPointForCoordinate(origin);
		CLLocationCoordinate2D corner = CLLocationCoordinate2DMake(minLat, maxLon);
		MKMapPoint lowerRight = MKMapPointForCoordinate(corner);
		
		double width = lowerRight.x - upperLeft.x;
		double height = lowerRight.y - upperLeft.y;
		boundingMapRect = MKMapRectMake(upperLeft.x, upperLeft.y, width, height);
	}
	return self;
}

// Create a straight line from c1 to c2. It's used to show walking direction in the trip planner.
- (id)initWithCoordinate:(CLLocationCoordinate2D)c1 andCoordinate:(CLLocationCoordinate2D)c2 {
	if (self = [super init]) {
		self.points = [NSArray arrayWithObjects:
					   [NSData dataWithBytes:&c1 length:sizeof(CLLocationCoordinate2D)],
					   [NSData dataWithBytes:&c2 length:sizeof(CLLocationCoordinate2D)],
					   nil];
		
		double minLat = MIN(c1.latitude, c2.latitude);
		double minLon = MIN(c1.longitude, c2.longitude);
		double maxLat = MAX(c1.latitude, c2.latitude);
		double maxLon = MAX(c1.longitude, c2.longitude);
		CLLocationCoordinate2D origin = CLLocationCoordinate2DMake(maxLat, minLon);
		MKMapPoint upperLeft = MKMapPointForCoordinate(origin);
		CLLocationCoordinate2D corner = CLLocationCoordinate2DMake(minLat, maxLon);
		MKMapPoint lowerRight = MKMapPointForCoordinate(corner);
		double width = lowerRight.x - upperLeft.x;
		double height = lowerRight.y - upperLeft.y;
		boundingMapRect = MKMapRectMake(upperLeft.x, upperLeft.y, width, height);
	}
	return self;
}

- (id)copyWithZone:(NSZone*)zone {
	CUShape *shape = [[CUShape allocWithZone:zone] init];
	shape.points = points;
	shape.boundingMapRect = boundingMapRect;
	shape.highlighted = highlighted;
	return shape;
}

- (CLLocationCoordinate2D)coordinate {
	return CLLocationCoordinate2DMake(0, 0);
}

- (void)dealloc {
	[points release];
	[super dealloc];
}

@end
