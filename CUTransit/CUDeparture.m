//
//  CUDeparture.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CUDeparture.h"
#import "CUTrip.h"
#import "common.h"

@implementation CUDeparture

@synthesize headsign, expectedMinutes, coordinate, trip, vehicleID, expected, destinationStopID;

- (id)initWithDictionary:(id)dic {
	if (self = [super init]) {
		self.headsign = [dic objectForKey:@"headsign"];
		expectedMinutes = [[dic objectForKey:@"expected_mins"] intValue];
		NSDictionary *locationDic = [dic objectForKey:@"location"];
		coordinate.latitude = [[locationDic objectForKey:@"lat"] doubleValue];
		coordinate.longitude = [[locationDic objectForKey:@"lon"] doubleValue];
		self.trip = [[[CUTrip alloc] initWithDictionary:[dic objectForKey:@"trip"]] autorelease];
		self.vehicleID = [dic objectForKey:@"vehicle_id"];
		self.expected = formattedTime([dic objectForKey:@"expected"]);
		self.destinationStopID = [[dic objectForKey:@"destination"] objectForKey:@"stop_id"];
	}
	return self;
}

- (NSString*)title {
	return headsign;
}

- (NSString*)subtitle {
	if (![trip.tripHeadsign isKindOfClass:[NSString class]]) // could be NSNull
		return nil;
	return trip.tripHeadsign;
}

- (void)dealloc {
	[headsign release];
	[expected release];
	[destinationStopID release];
	[super dealloc];
}

@end
