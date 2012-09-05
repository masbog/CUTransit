//
//  CUConnection.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CUConnection.h"
#import "config.h"
#import "StopDatabase.h"

@implementation CUConnection

- (id)init {
	if (self = [super init]) {
		queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

+ (CUConnection*)sharedConnection {
	static CUConnection *sharedConnection = nil;
	if (sharedConnection == nil) {
		sharedConnection = [[CUConnection alloc] init];
	}
	return sharedConnection;
}

- (NSURL*)urlWithMethod:(NSString*)method arguments:(NSString*)args {
	NSString *s = [NSString stringWithFormat:@"http://developer.cumtd.com/api/v2.1/json/%@?key=%@&%@", method, CUMTD_APIKEY, args];
	return [NSURL URLWithString:s];
}

- (void)sendRequestWithMethod:(NSString*)method arguments:(NSString*)args handler:(CUHandler)handler process:(id (^)(id obj)) process{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	pendingRequestCount++;
	
	NSURL *url = [self urlWithMethod:method arguments:args];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:
	 ^(NSURLResponse *res, NSData *data, NSError *error) {
		 pendingRequestCount--;
		 if (pendingRequestCount == 0)
			 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		 
		 if (data) {
			 NSError *error2;
			 id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error2];
			 if (obj) {
				 CUError *error = [[CUError alloc] init];
				 error.code = [[[obj objectForKey:@"status"] objectForKey:@"code"] intValue];
				 error.message = [[obj objectForKey:@"status"] objectForKey:@"msg"];
				 id data = process(obj);
				 handler(data, error);
				 [error release];
			 } else {
				 CUError *error = [[CUError alloc] init];
				 error.message = @"Invalid response from the server.";
				 handler(nil, error); // fail because of bad json
				 [error release];
			 }
		 } else {
			 CUError *error2 = [[CUError alloc] init];
			 error2.code = error.code;
			 error2.message = error.localizedDescription;
			 handler(nil, error2); // fail because of no response
			 [error2 release];
		 }
	 }
	 ];
	[request release];
}

- (void)requestDeparturesByStopID:(NSString*)stopID lookAhead:(BOOL)lookAhead handler:(CUHandler)handler {
	NSString *args;
	if (!lookAhead) {
		args = [NSString stringWithFormat:@"stop_id=%@", stopID]; //TODO: might need escaping
	} else {
		args = [NSString stringWithFormat:@"stop_id=%@&pt=60", stopID]; //TODO: might need escaping
	}
	[self sendRequestWithMethod:@"GetDeparturesByStop" arguments:args handler:handler process:
	 ^(id obj) {
		 NSMutableArray *ret = [NSMutableArray array];
		 NSArray *departures = [obj objectForKey:@"departures"];
		 for (NSDictionary *departure in departures) {
			 CUDeparture *tmp = [[CUDeparture alloc] initWithDictionary:departure];
			 [ret addObject:tmp];
			 [tmp release];
		 }
		 return ret;
	 }
	 ];
}

// too slow, use offline data instead
/*
- (void)requestStopsUsingHandler:(CUHandler)handler {
	[self sendRequestWithMethod:@"GetStops" arguments:@"" handler:handler process:
	 ^(id obj) {
		 NSMutableArray *ret = [NSMutableArray array];
		 NSArray *stops = [obj objectForKey:@"stops"];
		 for (NSDictionary *stop in stops) {
			 CUStop *tmp = [[CUStop alloc] initWithDictionary:stop];
			 [ret addObject:tmp];
			 [tmp release];
		 }
		 return ret;
	 }
	 ];
}
*/

- (void)requestStopsBySearch:(NSString*)query handler:(CUHandler)handler {
#if USE_ONLINE_STOP_AUTOCOMPLETE
	query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *args = [NSString stringWithFormat:@"query=%@", query];
	[self sendRequestWithMethod:@"GetStopsBySearch" arguments:args handler:handler process:
	 ^(id obj) {
		 NSMutableArray *ret = [NSMutableArray array];
		 NSArray *stops = [obj objectForKey:@"stops"];
		 for (NSDictionary *stop in stops) {
			 CUStop *tmp = [[CUStop alloc] initWithDictionary:stop];
			 [ret addObject:tmp];
			 [tmp release];
		 }
		 return ret;
	 }
	 ];
#else
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		NSArray *stops = [StopDatabase stopsWithQuery:query];
		handler(stops, nil);
	});
#endif
}

- (void)requestShapeByShapeID:(NSString*)shapeID handler:(CUHandler)handler {
	shapeID = [shapeID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *args = [NSString stringWithFormat:@"shape_id=%@", shapeID];
	[self sendRequestWithMethod:@"GetShape" arguments:args handler:handler process:
	 ^(id obj) {
		 NSArray *shapes = [obj objectForKey:@"shapes"];
		 CUShape *tmp = [[CUShape alloc] initWithObject:shapes];
		 return [tmp autorelease];
	 }
	 ];
}

- (void)requestShapeBetweenStopID:(NSString*)beginStopID andStopID:(NSString*)endStopID shapeID:(NSString*)shapeID handler:(CUHandler)handler {
	shapeID = [shapeID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *args = [NSString stringWithFormat:@"begin_stop_id=%@&end_stop_id=%@&shape_id=%@", beginStopID, endStopID, shapeID];
	[self sendRequestWithMethod:@"GetShapeBetweenStops" arguments:args handler:handler process:
	 ^(id obj) {
		 NSArray *shapes = [obj objectForKey:@"shapes"];
		 CUShape *tmp = [[CUShape alloc] initWithObject:shapes];
		 return [tmp autorelease];
	 }
	 ];
}

- (void)requestPlannedTripsByOriginStopID:(NSString*)originStopID destinationStopID:(NSString*)destStopID handler:(CUHandler)handler {
	NSString *args = [NSString stringWithFormat:@"origin_stop_id=%@&destination_stop_id=%@", originStopID, destStopID]; //TODO: might need escaping
	[self sendRequestWithMethod:@"GetPlannedTripsByStops" arguments:args handler:handler process:
	 ^(id obj) {
		 NSMutableArray *ret = [NSMutableArray array];
		 NSArray *itineraries = [obj objectForKey:@"itineraries"];
		 for (NSDictionary *itinerary in itineraries) {
			 CUItinerary *tmp = [[CUItinerary alloc] initWithDictionary:itinerary];
			 [ret addObject:tmp];
			 [tmp release];
		 }
		 return ret;
	 }
	 ];
}

- (void)requestPlannedTripsByOriginCoordinate:(CLLocationCoordinate2D)originCoordinate destinationCoordinate:(CLLocationCoordinate2D)destCoordinate handler:(CUHandler)handler {
	NSString *args = [NSString stringWithFormat:@"origin_lat=%f&origin_lon=%f&destination_lat=%f&destination_lon=%f",
					  originCoordinate.latitude, originCoordinate.longitude, destCoordinate.latitude, destCoordinate.longitude];
	[self sendRequestWithMethod:@"GetPlannedTripsByLatLon" arguments:args handler:handler process:
	 ^(id obj) {
		 NSMutableArray *ret = [NSMutableArray array];
		 NSArray *itineraries = [obj objectForKey:@"itineraries"];
		 for (NSDictionary *itinerary in itineraries) {
			 CUItinerary *tmp = [[CUItinerary alloc] initWithDictionary:itinerary];
			 [ret addObject:tmp];
			 [tmp release];
		 }
		 return ret;
	 }
	 ];
}

- (void)dealloc {
	[queue release];
	[super dealloc];
}

@end
