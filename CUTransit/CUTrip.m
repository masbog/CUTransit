//
//  CUTrip.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CUTrip.h"

@implementation CUTrip

@synthesize routeID, shapeID, tripHeadsign;

- (id)initWithDictionary:(id)dic {
	if (self = [super init]) {
		self.routeID = [dic objectForKey:@"route_id"];
		self.shapeID = [dic objectForKey:@"shape_id"];
		self.tripHeadsign = [dic objectForKey:@"trip_headsign"];
	}
	return self;
}

- (void)dealloc {
	[routeID release];
	[shapeID release];
	[tripHeadsign release];
	[super dealloc];
}

@end
