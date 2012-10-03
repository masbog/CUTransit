//
//  Location.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "Location.h"
#import "config.h"
#import "common.h"

@implementation Location

@synthesize type, stop, text, coordinate, handler;

- (id)init {
	if (self = [super init]) {
		queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (void)geocodeWithCoordinate:(CLLocationCoordinate2D)coor {
#ifdef GOOGLEMAP_APIKEY
	// http://code.google.com/apis/maps/documentation/places/#PlaceSearches
	NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%lf,%lf&radius=1600&name=%@&sensor=true&key=%@",
						coor.latitude,
						coor.longitude,
						[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						GOOGLEMAP_APIKEY];
	
	NSURL *url = [NSURL URLWithString:urlStr];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:
	 ^(NSURLResponse *res, NSData *data, NSError *error) {
		 if (data) {
			 id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			 if (obj) {
				 NSString *status = [obj objectForKey:@"status"];
				 if ([status isEqualToString:@"OK"]) {
					 NSDictionary *result = [[obj objectForKey:@"results"] objectAtIndex:0];
					 NSDictionary *location = [[result objectForKey:@"geometry"] objectForKey:@"location"];
					 
					 self.text = [result objectForKey:@"name"];
					 double latitude = [[location objectForKey:@"lat"] doubleValue];
					 double longitude = [[location objectForKey:@"lng"] doubleValue];
					 type = LocationTypeCoordinate;
					 coordinate = CLLocationCoordinate2DMake(latitude, longitude);
					 
					 handler(YES, nil);
				 } else if ([status isEqualToString:@"ZERO_RESULTS"]) {
					 NSError *error = errorWithDescription(0, @"Try using more specific address. You can also pinpoint it on a map.");
					 handler(NO, error);
				 } else {
					 NSError *error = errorWithDescription(0, status);
					 handler(NO, error);
				 }
			 } else {
				 handler(NO, nil); // fail because of bad json
			 }
		 } else {
			 handler(NO, error);
		 }
	 }
	 ];
	[request release];
#else
	// fall back to Apple's geocoder
	
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coor radius:20000 identifier:@""];
	[geocoder geocodeAddressString:text inRegion:region completionHandler:
	 ^(NSArray *placemarks, NSError *error) {
		 if ([placemarks count] > 0) {
			 CLPlacemark *placemark = [placemarks objectAtIndex:0];
			 
			 type = LocationTypeCoordinate;
			 coordinate = placemark.location.coordinate;
			 
			 handler(YES, nil);
		 } else {
			 handler(NO, error);
		 }
	 }];
	[region release];
	[geocoder release];
#endif
}

// Locations of type Text and CurrentLocation must be resolved before using
// to find the exact coordinates.
- (void)resolveWithHandler:(void(^)(BOOL success, NSError *error))_handler {
	if (type == LocationTypeCurrentLocation) {
		self.handler = _handler;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			CLLocationManager *locationManager = [[CLLocationManager alloc] init];
			locationManager.delegate = self;
			locationManager.desiredAccuracy = kCLLocationAccuracyBest;
			[locationManager startUpdatingLocation];
		});
	} else if (type == LocationTypeText) {
		if (text == nil || [text length] == 0) {
			_handler(NO, nil);
			return;
		}
		
		CUConnection *con = [CUConnection sharedConnection];
		[con requestStopsBySearch:text handler:
		 ^(id data, CUError *error) {
			 NSArray *stops = data;
			 if ([stops count] > 0) {
				 //TODO: if there are more than one stop that match the text, ask user which one to use.
				 type = LocationTypeStop;
				 self.stop = [stops objectAtIndex:0];
				 self.text = stop.stopName;
				 
				 _handler(YES, nil);
			 } else {
				 self.handler = _handler;
				 
				 // use the current location as a hint
				 dispatch_async(dispatch_get_main_queue(), ^{
					 CLLocationManager *locationManager = [[CLLocationManager alloc] init];
					 locationManager.delegate = self;
					 locationManager.desiredAccuracy = kCLLocationAccuracyBest;
					 [locationManager startUpdatingLocation];
				 });
			 }
		 }
		 ];
	} else {
		_handler(YES, nil);
	}
}

#pragma mark - Location manager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	[manager stopUpdatingLocation];
	
	if (type == LocationTypeCurrentLocation) {
		coordinate = newLocation.coordinate;
		self.text = @"Current Location";
		
		handler(YES, nil);
	} else if (type == LocationTypeText) {
		[self geocodeWithCoordinate:newLocation.coordinate];
	}
	
	[manager release];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if (error.domain == kCLErrorDomain && error.code == kCLErrorDenied) {
		handler(NO, errorWithDescription(0, @"Please go to Settings > Location Services and enable this app."));
	} else {
		handler(NO, error);
	}
	[manager stopUpdatingLocation];
	[manager release];
}

#pragma mark - Annotation

- (NSString*)title {
	if (type == LocationTypeStop)
		return stop.stopName;
	if (type == LocationTypeCoordinate)
		return text;
	if (type == LocationTypeCurrentLocation)
		return text; // which is "Current Location"
	return @"";
}

- (NSString*)subtitle {
	if (type == LocationTypeStop)
		return stop.code;
	if (type == LocationTypeCoordinate)
		return @"";
	return @"";
}

- (CLLocationCoordinate2D)coordinate {
	if (type == LocationTypeStop)
		return stop.coordinate;
	return coordinate;
}

- (void)dealloc {
	[stop release];
	[text release];
	[queue release];
	[handler release];
	[super dealloc];
}

@end
